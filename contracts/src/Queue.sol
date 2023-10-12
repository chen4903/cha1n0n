// SPDX-License-Identifier: MIT
// https://ethereum.stackexchange.com/questions/129668/how-to-efficiently-implement-a-fifo-array-queue-in-solidity
// pragma solidity ^0.8.0;
// 这个代码写的是有错的, transferUserRightPending()的FIFO模型参考了这个代码
// contract Queue {
//     mapping (uint256 => uint256 /* or any other type */ ) public queue;
//     uint256 first = 1;
//     uint256 last = 1;
//     function enqueue(uint256 data) public {
//         queue[last] = data;
//         last += 1;
//     }

//     function dequeue() public returns (uint256) {
//         require(last > first);
//         uint256 data = queue[first];
//         delete queue[first];
//         first += 1;
//         return data
//     }

//     function length() public view returns (uint256) {
//         return last - first;
//     }
// }

  