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
    address payable musicPlatform = payable(0x0000000000000000000000000000000000000088);

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
        musicPlatform.transfer(10 ether);
    }

    // 测试：订阅、转让专辑、FIFO的转让规则、市场有人卖就不订阅而是交易、市场长度计算
    function test_describe_transferRight() public{

        vm.startBroadcast(singer01);
        // 注册成为歌手
        core.updateSongAndAlbum(10, hex"00000000");
        // 上传专辑
        core.updateSongAndAlbum(999, hex"00000001");
        vm.stopBroadcast();

        vm.startBroadcast(user01);
        // 订阅歌手
        core.describe{value: 10}(singer01, hex"00000000");
        // 订阅专辑
        core.describe{value: 999}(singer01, hex"00000001");
        vm.stopBroadcast();

        vm.startBroadcast(user02);
        // 订阅歌手
        core.describe{value: 10}(singer01, hex"00000000");
        // 订阅专辑
        core.describe{value: 999}(singer01, hex"00000001");
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
        core.describe{value: 999}(singer01, hex"00000001");
        uint256 balUser01After = user01.balance;
        uint256 balUser02After = user02.balance;
        // 检查：是user03从user01手中买，而不是重新订阅
        assertEq(core.userDescribeAlbums(user01,singer01,hex"00000001"), false);
        assertEq(balUser01Before + 999, balUser01After);
        // 检查：user02的权益尚未在市场交易走
        assertEq(balUser02Before, balUser02After);
        assertEq(core.userDescribeAlbums(user02,singer01,hex"00000001"), true);
        vm.stopBroadcast();

        vm.startBroadcast(user04);
        uint256 balUser02Before_ = user02.balance;
        vm.expectEmit(true, true, true, true);
        emit SwapRightAlbum(singer01, user02, user04, hex"00000001");
        core.describe{value: 999}(singer01, hex"00000001");
        uint256 balUser02After_ = user02.balance;
        // 检查：是user04从user02手中买，而不是重新订阅
        assertEq(core.userDescribeAlbums(user02,singer01,hex"00000001"), false);
        assertEq(core.userDescribeAlbums(user04,singer01,hex"00000001"), true);
        assertEq(balUser02Before_ + 999, balUser02After_);
        vm.stopBroadcast();

        vm.startBroadcast(user05);
        vm.expectEmit(true, true, true, true);
        emit DescribeAlnum(singer01, user05, hex"00000001");
        core.describe{value: 999}(singer01, hex"00000001");
        // 检查：user05订阅专辑成功
        assertEq(core.userDescribeAlbums(user05,singer01,hex"00000001"), true);
        vm.stopBroadcast();
    }

    function test_investSinger() public{
        
        vm.startBroadcast(musicPlatform);
        // 音乐平台事先转钱给接口平台
        payable(address(this)).transfer(2 ether);
        vm.stopBroadcast();

        // 接口平台作为owner，有权力帮助音乐平台投资
        core.investSinger{value: 2 ether}(singer01, musicPlatform);

    }

    receive() external payable{}
}