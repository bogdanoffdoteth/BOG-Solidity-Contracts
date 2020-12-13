pragma solidity ^0.5.5;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/AllowanceCrowdsale.sol";

contract BogCrowdsale is AllowanceCrowdsale{
    address private _deployer;
    bool private _isOpen;
    uint256 private constant decimalFactor = 10**18;
    uint256 private _currRate;
    uint256 private _tokenRaised;

    mapping(address => uint256) _contribution;

    modifier onlyOwner(){
        require(_deployer == msg.sender, "Caller is not the owner");
        _;
    }
    constructor(uint256 rate, address payable wallet, IERC20 token ) public
    AllowanceCrowdsale(wallet)
    Crowdsale(rate,wallet,token){
        _deployer = msg.sender;
        _currRate = rate;

    }

    //getters
    function isOpen() public view returns(bool){
        return _isOpen;
    }

    function tokenRaised() public view returns(uint256){
        return _tokenRaised;
    }





    function contribution(address target) public view returns(uint256){
        return _contribution[target];
    }

    function currentRate() public view returns(uint256){
        return _currRate;
    }

    function setRate(uint256 rate) internal{
        _currRate = rate;

    }



    // toggle between opening and closing crowdsale
    function toggleSale() public onlyOwner{
        _isOpen = !_isOpen;
    }



    /**
     * The base rate function is overridden to revert, since this crowdsale doesn't use it, and
     * all calls to it are a mistake.
     */
    function rate() public view returns (uint256) {
        revert("rate() called but not used");
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return currentRate().mul(weiAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view{
        require(isOpen(), "Crowdsale is closed");
        require(_getTokenAmount(weiAmount)<=remainingTokens(), "Token sold out");
        require(weiAmount>=(10**17), "Minimum 0.1 ETH contribution");
        require(weiAmount.add(contribution(beneficiary))<= 10 * decimalFactor, "Maximum 10 ETH contribution");
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal{
        _contribution[beneficiary] = _contribution[beneficiary].add(weiAmount);
        _tokenRaised = tokenRaised() + _getTokenAmount(weiAmount);
        if(tokenRaised()>=uint256(900000).mul(decimalFactor) && currentRate() != 2000){
            setRate(2000);
        }else if(tokenRaised()>=uint256(300000).mul(decimalFactor) && currentRate() != 2500){
            setRate(2500);
        }
    }
}
