// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Core{
    // 用户=>歌手名单(包括历史订阅与目前订阅)
    mapping(address=>address[]) public userDescribeSingersList;
    // 用户=>歌手=>目前是否订阅
    mapping(address=>mapping(address=>bool)) public userDescribeSingers;
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


    constructor() public{
        owner = msg.sender;
    }

    modifier onlyOnwer(){
        require(msg.sender == owner, "not the owner");
        _;
    }

    // 用户：订阅歌手/专辑
    function describe(address _singer, bytes4 _albumName) external payable{
        if(_albumName == hex"00000000"){ // 订阅歌手
            require(singerSongs[_singer].price != 0, "The singer hasn't registered yet");
            require(msg.value >= singerSongs[_singer].price, "not enough money");
            require(userDescribeSingers[msg.sender][_singer] == false, "u have described the singer");

            // 看看有没有人卖，有的话交易
            if(queueSongNumber[_singer].last > queueSongNumber[_singer].first){
                // 实现队列，用数组push和pop会出现前面提交订单的可能永远无法被交易
                address seller = swapSongMarket[_singer][queueSongNumber[_singer].first];
                uint256 amount = singerSongs[_singer].price;
                delete swapSongMarket[_singer][queueSongNumber[_singer].first];
                queueSongNumber[_singer].first += 1;

                // 买方得到权益
                userDescribeSingersList[msg.sender].push(_singer);
                userDescribeSingers[msg.sender][_singer] = true;
                // 卖方失去权益
                userDescribeSingers[seller][_singer] = false;

                payable(seller).transfer(amount); // TODO 检查是否是合约，否则会出现DoS
            }else{ // 没的话就买
                userDescribeSingersList[msg.sender].push(_singer);
                userDescribeSingers[msg.sender][_singer] = true;
                singerSongs[_singer].totalReward += singerSongs[_singer].price;
            }
        }else{ // 订阅专辑
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

    // 用户：转移权益：歌手或者专辑
    function transferUserRightPending(address _singer, bytes4 _albumName) external{
        if(_albumName == hex"00000000"){ // 歌手
            require(singerSongs[_singer].price != 0, "The singer hasn't registered yet");
            require(userDescribeSingers[msg.sender][_singer] == true, "u haven't described the singer");

            swapSongMarket[_singer][queueSongNumber[_singer].last] = msg.sender;
            queueSongNumber[_singer].last += 1;
            
        }else{ // 专辑
            require(singerAlbums[_singer][_albumName].price != 0, "album not exist");
            require(userDescribeAlbums[msg.sender][_singer][_albumName] == true, "u haven't bought the album");

            swapAlbumMarket[_singer][_albumName][queueAlbumNumber[_singer][_albumName].last] = msg.sender;
            queueAlbumNumber[_singer][_albumName].last += 1;
            
        }
    }

    // 歌手：订阅价格与专辑上传
    function updateSongAndAlbum(uint256 _price,  bytes4 _albumName) external{
        if(_albumName == hex"00000000"){ // 普通歌曲
            singerSongs[msg.sender].singer = msg.sender;
            singerSongs[msg.sender].price = _price;
        }else{ // 专辑
            singerAlbumsList[msg.sender].push(_albumName);
            singerAlbums[msg.sender][_albumName].singer = msg.sender;
            singerAlbums[msg.sender][_albumName].price = _price;
        }
    }
    
    // 音乐平台：投资歌手。只允许owner操作，不能任何人都可以投资
    function investSinger(address _singer, address _musicPlatfrom) public payable onlyOnwer{
        singerSongs[_singer].totalAmount += msg.value;
        singerSongs[_singer].musicPlatform.push(_musicPlatfrom);
        singerSongs[_singer].musicPlatformAmount[_musicPlatfrom] += msg.value;
    }

    // 用于计算用户支付订阅和专辑的钱。因为每个季度分配钱之后，历史的收入不会刷新，因此需要一个变量记录上一次的收入，
    // 然后相减，就可以得到上次分配钱之后，又有多少新的收入（新一轮股市）
    mapping(address=>uint256) public lastRewardAmount;

    // 计算：歌手收益、音乐平台收益
    function calReward(address _singer, address _musicPlatfrom) public view returns(uint256){
        // TODO: 暂定如下
        // 普通歌曲收入
        uint256 songAmount = singerSongs[_singer].totalAmount;
        // 专辑订阅收入
        uint256 albumAmount;
        for(uint256 i = 0; i < singerAlbumsList[_singer].length;i++){
            albumAmount += singerAlbums[_singer][singerAlbumsList[_singer][i]].totalReward;
        }
        uint256 totalAmount = songAmount + albumAmount;
        // 歌手占收益的20%，各个_musicPlatfrom瓜分80%的收益
        // TODO 尚未经过数据精度处理
        return (singerSongs[_singer].musicPlatformAmount[_musicPlatfrom] / singerSongs[_singer].totalAmount * totalAmount) * 80 / 100; 
    }

    // 歌手拿走投资的钱。接口平台需要扣除手续费
    // 每一个季度刷新投资人的钱的时候，歌手才能拿走这些投资的钱
    function receiveAmountBySinger() public {
        // TODO
    }

    // 分配用户订阅的钱：歌手、音乐平台。接口平台需要扣除手续费
    // 每一个季度刷新投资人的钱的时候，歌手才能拿走这些投资的钱
    function sendMusicPlatformReward() public{
        // TODO
    }

    // 查看：市场中有多少歌曲或者专辑在卖
    function marketLength(address _singer, bytes4 _albumName) public view returns(uint256){
        if(_albumName == hex"00000000"){ // 普通歌曲
            return queueSongNumber[_singer].last - queueSongNumber[_singer].first;
        }else{ // 专辑
            return queueAlbumNumber[_singer][_albumName].last - queueAlbumNumber[_singer][_albumName].first;
        }
    }

    // 歌手：专辑下架，是否做呢？感觉这个功能没必要，歌手没理由说不给大家听这个专辑，自己藏着干啥。。
    //function cancelAlbum() public{}

}