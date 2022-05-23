pragma solidity ^0.5.17;
interface IKIP13 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
contract IKIP7 is IKIP13 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function safeTransfer(address recipient, uint256 amount, bytes memory data) public;
    function safeTransfer(address recipient, uint256 amount) public;
    function safeTransferFrom(address sender, address recipient, uint256 amount, bytes memory data) public;
    function safeTransferFrom(address sender, address recipient, uint256 amount) public;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract KIP13 is IKIP13 {
    bytes4 private constant _INTERFACE_ID_KIP13 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor () internal {
        _registerInterface(_INTERFACE_ID_KIP13);
    }
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "KIP13: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
contract IKIP7Receiver {
    function onKIP7Received(address _operator, address _from, uint256 _amount, bytes memory _data) public returns (bytes4);
}
contract KIP7 is KIP13, IKIP7 {
    using SafeMath for uint256;
    using Address for address;
    bytes4 private constant _KIP7_RECEIVED = 0x9d188c22;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    bytes4 private constant _INTERFACE_ID_KIP7 = 0x65787371;
    constructor () public {
        _registerInterface(_INTERFACE_ID_KIP7);
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function safeTransfer(address recipient, uint256 amount) public {
        safeTransfer(recipient, amount, "");
    }
    function safeTransfer(address recipient, uint256 amount, bytes memory data) public {
        transfer(recipient, amount);
        require(_checkOnKIP7Received(msg.sender, recipient, amount, data), "KIP7: transfer to non KIP7Receiver implementer");
    }
    function safeTransferFrom(address sender, address recipient, uint256 amount) public {
        safeTransferFrom(sender, recipient, amount, "");
    }
    function safeTransferFrom(address sender, address recipient, uint256 amount, bytes memory data) public {
        transferFrom(sender, recipient, amount);
        require(_checkOnKIP7Received(sender, recipient, amount, data), "KIP7: transfer to non KIP7Receiver implementer");
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "KIP7: transfer from the zero address");
        require(recipient != address(0), "KIP7: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "KIP7: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "KIP7: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "KIP7: approve from the zero address");
        require(spender != address(0), "KIP7: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
    function _checkOnKIP7Received(address sender, address recipient, uint256 amount, bytes memory _data) internal returns (bool) {
        if (!recipient.isContract()) {
            return true;
        }

        bytes4 retval = IKIP7Receiver(recipient).onKIP7Received(msg.sender, sender, amount, _data);
        return (retval == _KIP7_RECEIVED);
    }
}
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
contract MinterRole {
    using Roles for Roles.Role;
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    Roles.Role private _minters;
    constructor () internal {
        _addMinter(msg.sender);
    }
    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }
    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }
    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }
    function renounceMinter() public {
        _removeMinter(msg.sender);
    }
    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }
    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}
contract KIP7Mintable is KIP13, KIP7, MinterRole {
    bytes4 private constant _INTERFACE_ID_KIP7MINTABLE = 0xeab83e20;
    constructor () public {
        _registerInterface(_INTERFACE_ID_KIP7MINTABLE);
    }
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}
contract KIP7Burnable is KIP13, KIP7 {
    bytes4 private constant _INTERFACE_ID_KIP7BURNABLE = 0x3b5a0bf8;
    constructor () public {
        _registerInterface(_INTERFACE_ID_KIP7BURNABLE);
    }
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}
contract PauserRole {
    using Roles for Roles.Role;
    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);
    Roles.Role private _pausers;
    constructor () internal {
        _addPauser(msg.sender);
    }
    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }
    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }
    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }
    function renouncePauser() public {
        _removePauser(msg.sender);
    }
    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }
    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor () internal {
        _paused = false;
    }
    function paused() public view returns (bool) {
        return _paused;
    }
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}
contract KIP7Pausable is KIP13, KIP7, Pausable {
    bytes4 private constant _INTERFACE_ID_KIP7PAUSABLE = 0x4d5507ff;
    constructor () public {
        _registerInterface(_INTERFACE_ID_KIP7PAUSABLE);
    }
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }
    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }
    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }
}
contract KIP7Metadata is KIP13, IKIP7 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    bytes4 private constant _INTERFACE_ID_KIP7_METADATA = 0xa219a025;
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _registerInterface(_INTERFACE_ID_KIP7_METADATA);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}
contract CREATE_TOKEN_KLAYTN is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata {
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply, address recipient) KIP7Metadata(name, symbol, decimals) public {
    	_mint(recipient, initialSupply);
    }
}

contract SET_TOKEN_KLAYTN is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata {
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply, address recipient) KIP7Metadata(name, symbol, decimals) public {
    }
}
