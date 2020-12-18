/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {CPVesting} from "./CPVesting.sol";
import {IERC20} from "../../intf/IERC20.sol";
import {IPermissionManager} from "../../lib/PermissionManager.sol";
import {IFeeRateModel} from "../../lib/FeeRateModel.sol";
import {SafeMath} from "../../lib/SafeMath.sol";

contract CP is CPVesting {
    using SafeMath for uint256;

    function init(
        address[] calldata addressList,
        uint256[] calldata timeLine,
        uint256[] calldata valueList
    ) external {
        /*
        Address List
        0. owner
        1. maintainer
        2. baseToken
        3. quoteToken
        4. permissionManager
        5. feeRateModel
        6. poolFactory
      */

        require(addressList.length == 7, "LIST_LENGTH_WRONG");

        initOwner(addressList[0]);
        _MAINTAINER_ = addressList[1];
        _BASE_TOKEN_ = IERC20(addressList[2]);
        _QUOTE_TOKEN_ = IERC20(addressList[3]);
        _BIDDER_PERMISSION_ = IPermissionManager(addressList[4]);
        _MT_FEE_RATE_MODEL_ = IFeeRateModel(addressList[5]);
        _POOL_FACTORY_ = addressList[6];

        /*
        Time Line
        0. phase bid starttime
        1. phase bid duration
        2. phase calm duration
        3. vesting duration
        */

        require(timeLine.length == 4, "LIST_LENGTH_WRONG");

        _PHASE_BID_STARTTIME_ = timeLine[0];
        _PHASE_BID_ENDTIME_ = _PHASE_BID_STARTTIME_.add(timeLine[1]);
        _PHASE_CALM_ENDTIME_ = _PHASE_BID_ENDTIME_.add(timeLine[2]);

        _VESTING_DURATION_ = timeLine[3];

        require(block.timestamp <= _PHASE_BID_STARTTIME_, "TIMELINE_WRONG");

        /*
        Value List
        0. pool quote cap
        1. owner quote ratio
        2. k
        3. i
        4. cliff rate
        */

        require(valueList.length == 4, "LIST_LENGTH_WRONG");

        _POOL_QUOTE_CAP_ = valueList[0];
        _OWNER_QUOTE_RATIO_ = valueList[1];
        _K_ = valueList[2];
        _I_ = valueList[3];
        _CLIFF_RATE_ = valueList[4];

        require(_I_ > 0 && _I_ <= 1e36, "I_VALUE_WRONG");
        require(_K_ <= 1e18, "K_VALUE_WRONG");
        require(_OWNER_QUOTE_RATIO_ <= 1e18, "OWNER_RATIO_WRONG");
        require(_CLIFF_RATE_ <= 1e18, "CLIFF_RATE_WRONG");

        _TOTAL_BASE_ = _BASE_TOKEN_.balanceOf(address(this));
    }
}
