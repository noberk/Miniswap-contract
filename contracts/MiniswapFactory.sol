// SPDX-License-Identifier: SimPL-2.0
pragma solidity=0.6.9;

import './interfaces/IMiniswapFactory.sol';
import './interfaces/IMiniswapMiner.sol';
import './MiniswapPair.sol';
import './MiniswapMiner.sol';

contract MiniswapFactory is IMiniswapFactory {
    address override public feeTo;
    address override public feeToSetter;
    address override public miner;
    address override public MINI;

    mapping(address => mapping(address => address)) override public getPair;
    address[] override public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _miner,address _mini,address _feeToSetter) public {
        feeToSetter = _feeToSetter;
        MINI = _mini;
        miner = _miner;
    }

    function allPairsLength() override external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) override external returns (address pair) {
        require(tokenA != tokenB, 'Miniswap: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Miniswap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Miniswap: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(MiniswapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IMiniswapPair(pair).initialize(miner,MINI,token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) override external {
        require(msg.sender == feeToSetter, 'Miniswap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) override external {
        require(msg.sender == feeToSetter, 'Miniswap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
