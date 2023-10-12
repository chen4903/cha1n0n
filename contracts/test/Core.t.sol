// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../src/Core.sol";

contract CoreTest is Test {
    Core core;

    // 用于测试
    address payable user01 = payable(0x0000000000000000000000000000000000000011);
    address payable user02 = payable(0x0000000000000000000000000000000000000022);
    address payable user03 = payable(0x0000000000000000000000000000000000000033);
    address payable user04 = payable(0x0000000000000000000000000000000000000044);
    address payable user05 = payable(0x0000000000000000000000000000000000000055);
    address payable singer01 = payable(0x0000000000000000000000000000000000000066);
    address payable singer02 = payable(0x0000000000000000000000000000000000000077);
    address payable musicPlatform01 = payable(0x0000000000000000000000000000000000000088);
    address payable musicPlatform02 = payable(0x0000000000000000000000000000000000000099);

    event DescribeAlnum(address singer, address user, bytes4 albumName);
    event SwapRightAlbum(address singer, address fromUser, address toUser, bytes4 albumName);

    function setUp() public{
        core = new Core(); 
        user01.transfer(10 ether);
        user02.transfer(10 ether);
        user03.transfer(10 ether);
        user04.transfer(10 ether);
        user05.transfer(10 ether);
        singer01.transfer(10 ether);
        singer02.transfer(10 ether);
        musicPlatform01.transfer(10 ether);
        musicPlatform02.transfer(10 ether);
    }

    // 测试：订阅、转让专辑、FIFO的转让规则、市场有人卖就不订阅而是交易、市场长度计算
    function test_describe_transferRight() public{
        // 准备describe
        vm.startBroadcast(user01);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user02);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user03);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user04);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user05);
        core.readyForDescribe();
        vm.stopBroadcast();

        vm.warp(block.timestamp + 1);

        vm.startBroadcast(singer01);
        // 注册成为歌手
        core.updateSongAndAlbum(100000, hex"00000000");
        // 上传专辑
        core.updateSongAndAlbum(9999999999, hex"00000001");
        vm.stopBroadcast();

        vm.startBroadcast(user01);
        // 订阅歌手
        core.describe{value: 100000}(singer01, hex"00000000",0);
        // 检查：是否订阅歌手成功
        assertEq(core.isDescribe(user01, singer01, hex"00000000"), true);
        assertEq(core.isDescribe(user05, singer01, hex"00000000"), false);
        assertEq(core.isDescribe(user01, singer02, hex"00000000"), false);
        // 订阅专辑
        core.describe{value: 9999999999}(singer01, hex"00000001",0);
        vm.stopBroadcast();

        vm.startBroadcast(user02);
        // 订阅歌手
        core.describe{value: 100000}(singer01, hex"00000000",0);
        // 订阅专辑
        core.describe{value: 9999999999}(singer01, hex"00000001",0);
        vm.stopBroadcast();

        vm.startBroadcast(user01);
        // user01不想听了专辑了，因此将这个专辑提交到市场等待别人交易
        core.transferUserRightPending(singer01, hex"00000001");
        vm.stopBroadcast();

        vm.startBroadcast(user02);
        // user02不想听了专辑了，因此将这个专辑提交到市场等待别人交易
        core.transferUserRightPending(singer01, hex"00000001");
        assertEq(core.marketLength(singer01, hex"00000000"), 0); // 0个普通歌在市场卖
        assertEq(core.marketLength(singer01, hex"00000001"), 2); // 2歌专辑在市场卖
        vm.stopBroadcast();

        vm.startBroadcast(user03);
        uint256 balUser01Before = user01.balance;
        uint256 balUser02Before = user02.balance;
        // user03订阅专辑
        core.describe{value: 9999999999}(singer01, hex"00000001",0);
        uint256 balUser01After = user01.balance;
        uint256 balUser02After = user02.balance;
        // 检查：是user03从user01手中买，而不是重新订阅
        assertEq(core.userDescribeAlbums(user01,singer01,hex"00000001"), false);
        assertEq(balUser01Before + 9999999999, balUser01After);
        // 检查：user02的权益尚未在市场交易走
        assertEq(balUser02Before, balUser02After);
        assertEq(core.userDescribeAlbums(user02,singer01,hex"00000001"), true);
        vm.stopBroadcast();

        vm.startBroadcast(user04);
        uint256 balUser02Before_ = user02.balance;
        vm.expectEmit(true, true, true, true);
        emit SwapRightAlbum(singer01, user02, user04, hex"00000001");
        core.describe{value: 9999999999}(singer01, hex"00000001",0);
        uint256 balUser02After_ = user02.balance;
        // 检查：是user04从user02手中买，而不是重新订阅
        assertEq(core.userDescribeAlbums(user02,singer01,hex"00000001"), false);
        assertEq(core.userDescribeAlbums(user04,singer01,hex"00000001"), true);
        assertEq(balUser02Before_ + 9999999999, balUser02After_);
        vm.stopBroadcast();

        vm.startBroadcast(user05);
        vm.expectEmit(true, true, true, true);
        emit DescribeAlnum(singer01, user05, hex"00000001");
        core.describe{value: 9999999999}(singer01, hex"00000001",0);
        // 检查：user05订阅专辑成功
        assertEq(core.userDescribeAlbums(user05,singer01,hex"00000001"), true);
        vm.stopBroadcast();

        vm.startBroadcast(user01);
        // user01不想听了普通歌曲了，因此将这个歌手提交到市场等待别人交易
        core.transferUserRightPending(singer01, hex"00000000");
        vm.stopBroadcast();

        uint256 user01BalBeforeSwapSong = user01.balance;
        vm.warp(block.timestamp + 1000000);

        vm.startBroadcast(user05);
        // 订阅歌手，从user01手上买
        core.describe{value: 100000}(singer01, hex"00000000",0);
        // 由于已经过了一段时间99s，因此user01得到的钱就不是原来的100000了
        uint256 user01BalAfterSwapSong = user01.balance;
        // 检查：user01因为出售歌手权益，因此可以拿到订阅的钱，不过随着时间推移，会减少一部分，拿到的比当初支付的价格少
        assert(user01BalAfterSwapSong - user01BalBeforeSwapSong < 100000);
        vm.stopBroadcast();

    }

    // 测试：owner投资、计算音乐平台的回报数额、分配奖金
    function test_investSinger_calReward() public{
        // 准备describe
        vm.startBroadcast(user01);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user02);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user03);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user04);
        core.readyForDescribe();
        vm.stopBroadcast();
        vm.startBroadcast(user05);
        core.readyForDescribe();
        vm.stopBroadcast();

        vm.warp(block.timestamp + 1);

        // musicPlatform01给singer01投资3ether，给singer02投资4ether，需要提前发送到合约，然后告诉接口平台方案。
        // musicPlatform02给singer01投资2ether，给singer02投资3ether，需要提前发送到合约，然后告诉接口平台方案。
        vm.startBroadcast(musicPlatform01);
        payable(this).transfer(7 ether);
        vm.stopBroadcast();
        vm.startBroadcast(musicPlatform02);
        payable(this).transfer(5 ether);
        vm.stopBroadcast();
        // 接口平台知道之后，onwer 构造数据，然后帮音乐平台进行投资
        address[] memory _musicPlatform = new address[](2);
        _musicPlatform[0] = musicPlatform01;
        _musicPlatform[1] = musicPlatform02;
        address[] memory _singer = new address[](2);
        _singer[0] = singer01;
        _singer[1] = singer02;
        uint256[][] memory _amount = new uint256[][](2);
        _amount[0] = new uint256[](2);
        _amount[1] = new uint256[](2);
        _amount[0][0] = 3 ether;
        _amount[0][1] = 4 ether;
        _amount[1][0] = 2 ether;
        _amount[1][1] = 3 ether;
        // 每一期，owner进行投资操作
        core.investSinger{value: 12 ether}(_musicPlatform, _singer, _amount);

        vm.startBroadcast(singer01);
        core.updateSongAndAlbum(100, hex"00000000"); // /singer01注册成为歌手，并设置订阅金额为100
        vm.stopBroadcast();
        vm.startBroadcast(singer02);
        core.updateSongAndAlbum(200, hex"00000000"); // /singer02注册成为歌手，并设置订阅金额为200
        vm.stopBroadcast();

        vm.startBroadcast(user01);
        core.describe{value: 100}(singer01, hex"00000000",0); // 订阅歌手singer01
        core.describe{value: 200}(singer02, hex"00000000",0); // 订阅歌手singer02
        vm.stopBroadcast();

        // 检查：计算投资回报公式是否正确
        // 对于singer01：用户充值收入池: 100，musicPlatform01占投资池比3/5，流量1/3
        // 因此收入: 100 * 0.8 * (3 / 5) * 2/3 + 100 * 0.8 * (1/3) * 1/3  = 40.888888888888886 ~= 40
        assertEq(core.calReward(singer01, musicPlatform01, address(0), 1, 3), 40);

        // 下面做一些测试用的数据准备，用来检查分配投资池和充值池之后的资金变化 --
        address[][] memory _musicPlatformToAlloc = new address[][](2);
        _musicPlatformToAlloc[0] = new address[](2);
        _musicPlatformToAlloc[1] = new address[](2);
        _musicPlatformToAlloc[0][0] = musicPlatform01;
        _musicPlatformToAlloc[0][1] = musicPlatform02;
        _musicPlatformToAlloc[1][0] = musicPlatform01;
        _musicPlatformToAlloc[1][1] = musicPlatform02;
            // --
        uint256[][] memory _molecular = new uint256[][](2);
        _molecular[0] = new uint256[](2);
        _molecular[1] = new uint256[](2);
        _molecular[0][0] = 1;
        _molecular[0][1] = 1;
        _molecular[1][0] = 1;
        _molecular[1][1] = 1;
        uint256[] memory _Denominator = new uint256[](2);
        _Denominator[0] = 2;
        _Denominator[1] = 2;
            // --
        uint256 musicPlatform01AllocBefore = musicPlatform01.balance;
        uint256 musicPlatform02AllocBefore = musicPlatform02.balance;
        uint256 singer01AllocBefore = singer01.balance;
        uint256 singer02AllocBefore = singer02.balance;
        uint256 ownerBefore = address(this).balance;
    
        core.allocMoney(_singer, _musicPlatformToAlloc, _molecular, _Denominator);

        uint256 musicPlatform01AllocAfter = musicPlatform01.balance;
        uint256 musicPlatform02AllocAfter = musicPlatform02.balance;
        uint256 singer01AllocAfter = singer01.balance;
        uint256 singer02AllocAfter = singer02.balance;
        uint256 ownerAfter = address(this).balance;

        // 每一轮分配奖金，都会使音乐平台、歌手、接口平台有收入
        assert(musicPlatform01AllocAfter > musicPlatform01AllocBefore);
        assert(musicPlatform02AllocAfter > musicPlatform02AllocBefore);
        assert(singer01AllocAfter > singer01AllocBefore);
        assert(singer02AllocAfter > singer02AllocBefore);
        assert(ownerAfter > ownerBefore);    
    }

    receive() external payable{}
}