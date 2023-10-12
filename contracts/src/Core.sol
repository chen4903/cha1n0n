// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Core{
    uint256 constant THREEMONTHS = 90 days;
    uint256 constant SIXMONTHS = 180 days;

    // 用户=>歌手名单(包括历史订阅与目前订阅)
    mapping(address=>address[]) public userDescribeSingersList;
    // 用户=>歌手=>目前是否订阅(根据时间)
    mapping(address=>mapping(address=>userTimeHelper)) public userDescribeSingers;
    struct userTimeHelper{
        uint256 start;
        uint256 end;
    }
    // 用户=>歌手=>专辑名单(包括历史订阅与目前订阅)
    mapping(address=>mapping(address=>bytes4[])) public userDescribeAlbumList;
    // 用户=>歌手=>专辑=>是否订阅
    mapping(address=>mapping(address=>mapping(bytes4=>bool))) public userDescribeAlbums;

    // 歌手=>普通歌曲池子
    mapping(address=>songPool) public singerSongs;
    // 歌手=>专辑池子
    mapping(address=>bytes4[]) public singerAlbumsList;
    mapping(address=>mapping(bytes4=>albumPool)) public singerAlbums;

    // 音乐平台=>歌手
    mapping(address=>address[]) public musicPlatform;

    // 池子：每一歌手对应一个结构体
    struct songPool{
        address singer; // 歌手
        uint256 price; // 价格
        uint256 totalReward; // 用户总投入金额
        uint256 totalAmount; // 投资总金额
        address[] musicPlatform; // 音乐平台
        mapping(address=>uint256) musicPlatformAmount; // 音乐平台投资多少钱
    }

    // 池子：每一首专辑对应一个结构体
    struct albumPool{
        address singer; // 歌手
        uint256 price; // 价格
        uint256 totalReward; // 用户总投入金额
    }

    // 歌手=>想出售的用户。用mapping实现FIFO
    mapping(address=>mapping(uint256=>address)) public swapSongMarket;
    mapping(address=>queueSongCount) public queueSongNumber;
    struct queueSongCount{
        uint256 first;
        uint256 last;
    }

    // 歌手=>专辑=>想出售的用户。用mapping实现FIFO
    mapping(address=>mapping(bytes4=>mapping(uint256=>address))) public swapAlbumMarket;
    mapping(address=>mapping(bytes4=>queueAlbumCount)) public queueAlbumNumber;
    struct queueAlbumCount{
        uint256 first;
        uint256 last;
    }

    address owner;

    event DescribeAlnum(address singer, address user, bytes4 albumName);
    event SwapRightAlbum(address singer, address fromUser, address toUser, bytes4 albumName);
    event DescribeSinger(address singer, address user, uint256 time);
    event SwapRightSinger(address singer, address fromUser, address toUser, uint256 time);
    event OrderPending(address singer, address seller,bytes4 albumName);
    event SingerUpdate(address singer, uint256 price,  bytes4 albumName);
    event InvestSinger(address[] musicPlatform, address[] singer, uint256[][] amount);
    event AllocMoney(address[] singer, address[][] musicPlatform, uint256[][] molecular, uint256[] Denominator);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not the owner");
        _;
    }

    mapping(address=>uint256) public isReadyForDescribe;
    function readyForDescribe() external {
        isReadyForDescribe[msg.sender] = block.timestamp;
    }

    // 用户：订阅歌手/专辑
    function describe(address _singer, bytes4 _albumName, uint256 _choice) external payable{
        // 只允许user是EOA账户，是为了防止DoS攻击。并且为了防止构造器攻击，增加了readyForDescribe()
        uint32 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }
        if(size > 0){ // 如果是合约
            revert("describer must be EOA");
        }else{
            require(isReadyForDescribe[msg.sender] < block.timestamp, "cannot ready and describe in the same tx");
            require(isReadyForDescribe[msg.sender] > 0, "have not readyForDescribe");
        }

        if(_albumName == hex"00000000"){ // 订阅歌手
            require(singerSongs[_singer].price != 0, "The singer hasn't registered yet");
            require(msg.value >= singerSongs[_singer].price, "not enough money");
            require(userDescribeSingers[msg.sender][_singer].start == 0
                    ||
                    userDescribeSingers[msg.sender][_singer].end <= block.timestamp, "have described the singer or service not yet expired");

            // 看看有没有人卖，有的话交易
            if(queueSongNumber[_singer].last > queueSongNumber[_singer].first ){
                // 实现队列，用数组push和pop会出现前面提交订单的可能永远无法被交易
                // 并且如果排在第一个的交易已经过期了，则排除掉
                while(true){
                    address sellerInner = swapSongMarket[_singer][queueSongNumber[_singer].first];
                    if(userDescribeSingers[sellerInner][_singer].end > block.timestamp){
                        // 找到队列中符合条件的交易对象
                        break;
                    }
                    delete swapSongMarket[_singer][queueSongNumber[_singer].first];
                    queueSongNumber[_singer].first += 1;
                    // 如果队列中的所有交易都是过期了，则直接订阅
                    if(queueSongNumber[_singer].last <= queueSongNumber[_singer].first ){
                        userDescribeSingersList[msg.sender].push(_singer);
                        userDescribeSingers[msg.sender][_singer].start = block.timestamp;
                        uint256 timeInner = _choice == 0 ? SIXMONTHS : THREEMONTHS; // 0 是 6个月， 其他参数是3个月
                        userDescribeSingers[msg.sender][_singer].end = block.timestamp + timeInner;
                        singerSongs[_singer].totalReward += singerSongs[_singer].price;

                        emit DescribeSinger(_singer, msg.sender, _choice == 0 ? SIXMONTHS : THREEMONTHS);
                        return;
                    }
                }

                address seller = swapSongMarket[_singer][queueSongNumber[_singer].first];
                uint256 price = singerSongs[_singer].price;

                // 根据时间计算应该返回的金额
                uint256 sellerStartTime = userDescribeSingers[seller][_singer].start;
                uint256 sellerEndTime = userDescribeSingers[seller][_singer].end;
                uint256 returnAmount = price * 
                    (  1000000000 *  (sellerEndTime - block.timestamp) / (sellerEndTime - sellerStartTime)    )  / 1000000000;

                // 买方得到权益
                userDescribeSingersList[msg.sender].push(_singer);
                userDescribeSingers[msg.sender][_singer].start = block.timestamp;
                uint256 time = _choice == 0 ? SIXMONTHS : THREEMONTHS; // 0 是 6个月， 其他参数是3个月
                userDescribeSingers[msg.sender][_singer].end = block.timestamp + time;
                // 卖方失去权益
                userDescribeSingers[seller][_singer].end = block.timestamp;

                singerSongs[_singer].totalReward += price;
                singerSongs[_singer].totalReward -= returnAmount;

                payable(seller).transfer(returnAmount); // TODO 检查是否是合约，否则会出现DoS

                emit SwapRightSinger(_singer, seller, msg.sender, _choice == 0 ? SIXMONTHS : THREEMONTHS);
            }else{ // 没的话就买
                userDescribeSingersList[msg.sender].push(_singer);
                userDescribeSingers[msg.sender][_singer].start = block.timestamp;
                uint256 time = _choice == 0 ? SIXMONTHS : THREEMONTHS; // 0 是 6个月， 其他参数是3个月
                userDescribeSingers[msg.sender][_singer].end = block.timestamp + time;
                singerSongs[_singer].totalReward += singerSongs[_singer].price;

                emit DescribeSinger(_singer, msg.sender, _choice == 0 ? SIXMONTHS : THREEMONTHS);
            }
        }else{ // 购买专辑
            require(singerAlbums[_singer][_albumName].price != 0, "album not exist");
            require(msg.value >= singerAlbums[_singer][_albumName].price , "not enough money");
            require(userDescribeAlbums[msg.sender][_singer][_albumName] == false, "u have bought the album");

            // 看看有没有人卖，有的话交易
            if(queueAlbumNumber[_singer][_albumName].last > queueAlbumNumber[_singer][_albumName].first){
                address seller = swapAlbumMarket[_singer][_albumName][queueAlbumNumber[_singer][_albumName].first];
                uint256 amount = singerAlbums[_singer][_albumName].price;
                delete swapAlbumMarket[_singer][_albumName][queueAlbumNumber[_singer][_albumName].first];
                queueAlbumNumber[_singer][_albumName].first += 1;

                // 买方得到权益
                userDescribeAlbumList[msg.sender][_singer].push(_albumName);
                userDescribeAlbums[msg.sender][_singer][_albumName] = true;
                // 卖方失去权益
                userDescribeAlbums[seller][_singer][_albumName] = false;

                payable(seller).transfer(amount); // TODO 检查是否是合约，否则会出现DoS
                emit SwapRightAlbum(_singer, seller, msg.sender, _albumName);
            }else{ // 没的话就买
                userDescribeAlbumList[msg.sender][_singer].push(_albumName);
                userDescribeAlbums[msg.sender][_singer][_albumName] = true;
                singerAlbums[_singer][_albumName].totalReward += singerAlbums[_singer][_albumName].price;

                emit DescribeAlnum(_singer, msg.sender, _albumName);
            }
        }

    }

    // 查看是否订阅歌手或者购买专辑
    function isDescribe(address _user, address _singer, bytes4 _albumName) public view returns(bool){
        if(_albumName == hex"00000000"){
            return userDescribeSingers[_user][_singer].start <= block.timestamp 
                && 
                    block.timestamp <= userDescribeSingers[_user][_singer].end;
        }else{
            return userDescribeAlbums[_user][_singer][_albumName] == true;
        }
    }

    // 用户：转移权益：歌手或者专辑
    function transferUserRightPending(address _singer, bytes4 _albumName) external{
        if(_albumName == hex"00000000"){ // 歌手
            require(singerSongs[_singer].price != 0, "The singer hasn't registered yet");
            require(userDescribeSingers[msg.sender][_singer].start <= block.timestamp
                && 
                block.timestamp <= userDescribeSingers[msg.sender][_singer].end,
                "u haven't described the singer"
            );

            swapSongMarket[_singer][queueSongNumber[_singer].last] = msg.sender;
            queueSongNumber[_singer].last += 1;
            emit OrderPending(_singer, msg.sender, hex"00000000");
        }else{ // 专辑
            require(singerAlbums[_singer][_albumName].price != 0, "album not exist");
            require(userDescribeAlbums[msg.sender][_singer][_albumName] == true, "u haven't bought the album");

            swapAlbumMarket[_singer][_albumName][queueAlbumNumber[_singer][_albumName].last] = msg.sender;
            queueAlbumNumber[_singer][_albumName].last += 1;
            
            emit OrderPending(_singer, msg.sender, _albumName);
        }
    }

    // 歌手：订阅价格与专辑上传
    function updateSongAndAlbum(uint256 _price,  bytes4 _albumName) external{
        if(_albumName == hex"00000000"){ // 普通歌曲
            singerSongs[msg.sender].singer = msg.sender;
            singerSongs[msg.sender].price = _price;

            emit SingerUpdate(msg.sender, _price, hex"00000000");
        }else{ // 专辑
            singerAlbumsList[msg.sender].push(_albumName);
            singerAlbums[msg.sender][_albumName].singer = msg.sender;
            singerAlbums[msg.sender][_albumName].price = _price;

            emit SingerUpdate(msg.sender, _price, _albumName);
        }
    }
    
    // 音乐平台：投资歌手。只允许owner操作，不能任何人都可以投资
    function investSinger(
        address[] calldata _musicPlatform, 
        address[] calldata _singer, 
        uint256[][] calldata amount
    ) external payable onlyOwner{
        uint256 platformLength = _musicPlatform.length;
        uint256 singerLength = _singer.length;
        uint256 totalAmount = 0;
        for(uint256 i = 0; i < platformLength; i++){
            for(uint256 j = 0; j < singerLength; j++){
                singerSongs[_singer[j]].totalAmount += amount[i][j];
                singerSongs[_singer[j]].musicPlatform.push(_musicPlatform[i]);
                singerSongs[_singer[j]].musicPlatformAmount[_musicPlatform[i]] += amount[i][j];
                totalAmount += amount[i][j];
            }
        }
        require(msg.value >= totalAmount, "not enough investMoney");

        emit InvestSinger(_musicPlatform,  _singer, amount);
    }

    // 用于计算用户支付订阅和专辑的钱。因为每个季度分配钱之后，历史的收入不会刷新，因此需要一个变量记录上一次的收入，
    // 然后相减，就可以得到上次分配钱之后，又有多少新的收入（新一轮股市）
    mapping(address=>uint256) public lastRewardAmount;

    // 计算充值池收益：歌手收益、音乐平台收益、接口平台手续费 
    function calReward(
        address _singer, 
        address _musicPlatform, 
        address _owner, 
        uint256 _molecular, 
        uint256 _Denominator
    ) public view returns(uint256){
        // 总投资
        uint256 investTotal = singerSongs[_singer].totalAmount; // stack too deep，因此在音乐平台投资的收入替换
        // 普通歌曲收入
        uint256 songAmount = singerSongs[_singer].totalReward; // stack too deep，因此在音乐平台投资的收入替换
        // 专辑购买收入
        uint256 albumAmount;
        for(uint256 i = 0; i < singerAlbumsList[_singer].length;i++){
            albumAmount += singerAlbums[_singer][singerAlbumsList[_singer][i]].totalReward;
        }
        // 总充值收入 = 普通歌曲收入 + 专辑购买收入 - 上次投资的时候已经分配的金额
        uint256 totalAmount = songAmount + albumAmount - lastRewardAmount[_singer];
        // 歌手占收益的15%，各个_musicPlatform瓜分80%的收益，平台收取5%手续费
        if(_musicPlatform == address(0) && _owner == address(0)){ // 歌手的收入
            return totalAmount * 15 / 100;
        }else if(_musicPlatform != address(0) && _owner == address(0)){ // 音乐平台投资的收入
            // [ (某音乐平台投资金额 / 全部音乐平台投资金额) * 充值池 * 2/3   + 某音乐平台流量比例 * 充值池 * 1/3     ] * 0.8     
            // 注意：100000用于解决精度损失
            // 原本：
            //             return (
            //     ((( 100000 * singerSongs[_singer].musicPlatformAmount[_musicPlatform] ) / singerSongs[_singer].totalAmount) * totalAmount *  2 / 3 / 100000) 
            // +   ((100000 *  _molecular / _Denominator) * totalAmount *  1 / 3 / 100000)
            // )
            // * 80 / 100; 
            // 由于直接这么return会造成stack too deep，因此分开写，用temp代替
            uint256 temp = 100000 * singerSongs[_singer].musicPlatformAmount[_musicPlatform];
            return (
                ((( temp ) / investTotal) * totalAmount *  2 / 3 / 100000) 
            +   ((100000 *  _molecular / _Denominator) * totalAmount *  1 / 3 / 100000)
            )
            * 80 / 100; 
        }else{ // 接口平台手续费
            return totalAmount * 5 / 100;
        }
    }

    // 每个投资季度开始，owner将投资池，然后进行新一轮的投资
    function allocMoney(
        address[] memory _singer, 
        address[][] memory _musicPlatform, 
        uint256[][] memory _molecular, 
        uint256[] memory _Denominator
    ) external onlyOwner{
        uint256 singerLength = _singer.length;

        // 分配充值池的钱
        for(uint256 i = 0; i < singerLength; i++){
            // 歌手
            payable(_singer[i]).transfer(calReward(_singer[i], address(0), address(0),0,0));
            // 手续费
            payable(owner).transfer(calReward(_singer[i],address(0), owner,0,0));
            for(uint256 j = 0; j < _musicPlatform[i].length; j++){
                // 音乐平台
                payable(_musicPlatform[i][j]).transfer(calReward(_singer[i], _musicPlatform[i][j], address(0), _molecular[i][j], _Denominator[i]));
            }
        }
        // 分配投资池的钱
        for(uint256 i = 0; i < singerLength; i++){
            uint256 totalInvest = singerSongs[_singer[i]].totalAmount;
            payable(_singer[i]).transfer(totalInvest * 80 / 100); // 歌手
            payable(_singer[i]).transfer(totalInvest * 20 / 100); // 手续费
        }

        // 清空投资池
        for(uint256 i = 0; i < singerLength; i++){
            singerSongs[_singer[i]].totalAmount = 0;
        }
        
        emit AllocMoney(_singer,  _musicPlatform, _molecular,  _Denominator);
    }

    // 查看：市场中有多少歌曲或者专辑在卖
    function marketLength(address _singer, bytes4 _albumName) external view returns(uint256){
        if(_albumName == hex"00000000"){ // 普通歌曲
            return queueSongNumber[_singer].last - queueSongNumber[_singer].first;
        }else{ // 专辑
            return queueAlbumNumber[_singer][_albumName].last - queueAlbumNumber[_singer][_albumName].first;
        }
    }

}