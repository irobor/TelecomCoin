pragma solidity ^0.5.0;


import "../token/ERC20/TelecomCoin.sol";
import "../utils/ReentrancyGuard.sol" ;


contract Crowdsale is ReentrancyGuard{
    
    using SafeMath for uint256;
    // The token being sold
    // Token это имя контракта самого токна, код токена нужно подключить через импорт
    TelecomToken private _token;
    
    // How many token units a buyer gets per wei.
    // Сколько токенов покупатель получает за вей.
    uint256 private _rate;
    
    // Address where funds are collected
    // Адрес кошелька где собирается сбор
    // С мультиподпесью. 
    address payable private _multisig;
    
    // Amount of wei raised
    // Количество вэй собрано этим контрактом
    uint256 private _weiRaised;
    
     /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     *
     * покупатель 
     * получатель
     * m weis оплачено за покупку
     * количество купленных токенов
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
    /**
     * @param rate Number of token units a buyer gets per wei 
     * @param wallet Address where collected funds will be forwarded to
     * @param token Address of the token being sold
     * 
     * Количество единиц токена, которые покупатель получает за вей
     * кошелек Адрес, куда собранные средства будут направлены
     * token Адрес продаваемого токена
     */
     constructor (uint256 rate, address payable wallet, TelecomToken token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _multisig = wallet;
        _token = token;
    }
   
	 /**
     * 
     */
    function () external payable {
        buyTokens(msg.sender);
    }
    
     /**
     * @return the token being sold.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the address where funds are collected.
     */
    function wallet() public view returns (address payable) {
        return _multisig;
    }

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }

    /**
     * @return the amount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }
    /**
     * @param beneficiary Recipient of the token purchase
     * beneficiary Покупатель токен
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        //рассчитать сумму токена, которая будет создана
        uint256 tokens = _getTokenAmount(weiAmount);

        // общее собранное кол-во ETH
        _weiRaised = _weiRaised.add(weiAmount);
        
        // запускаем mint
        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);
        
        // отправляет ETH на кошелёк miltisig
        _forwardFunds();
        
    }
    
    /**
     * @dev Source of tokens. Создание токена, mint
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.mint(beneficiary, tokenAmount);
    }
    
    /**
     * Валидация адреса покупателя и кол-во монет
     * @dev Validation of an incoming purchase. 
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal pure {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
    }
    
     /**
      *Конвертация эфира в токен 
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }
    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. 
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }
    
    
     function _forwardFunds() internal {
        _multisig.transfer(msg.value);
    }
    
}
