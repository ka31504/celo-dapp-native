# CELO DApp Suite: Ứng dụng Web3 sử dụng CELO làm phương tiện thanh toán

## 1. Tổng quan dự án

**CELO DApp Suite** là một bộ ứng dụng phi tập trung (DApp) triển khai trên **mạng Celo Sepolia Testnet**, sử dụng **đồng CELO** làm đơn vị thanh toán gốc.  
Dự án thể hiện cách xây dựng và triển khai các mô hình kinh tế Web3 phổ biến thông qua hợp đồng thông minh (smart contract) trên nền tảng tương thích EVM.

Bộ dự án bao gồm bốn hợp đồng thông minh chính:

| Tên ứng dụng | Chức năng |
|---------------|------------|
| Play-to-Earn (P2E) | Người chơi nhận thưởng CELO khi đạt điểm số tối thiểu |
| NFT Ticketing | Bán vé sự kiện dạng NFT (ERC-721), thanh toán bằng CELO |
| Creator Stream | Nhà tài trợ gửi dòng tiền CELO dần dần cho người sáng tạo nội dung |
| Pay-per-View (PPV) | Người xem trả CELO để xem nội dung có giới hạn thời gian |

Các hợp đồng được viết bằng **Solidity**, triển khai và kiểm thử trực tiếp trên **Remix IDE** kết hợp **MetaMask**.

---

## 2. Công nghệ sử dụng

- Ngôn ngữ: Solidity `^0.8.24`  
- Nền tảng: Celo Sepolia Testnet  
- Ví: MetaMask  
- Môi trường phát triển: Remix Ethereum IDE  
- Thư viện: OpenZeppelin (Ownable, ERC721, ReentrancyGuard)

---

## 3. Cấu trúc thư mục dự án

```
celo-dapp-native/
│
├── contracts/
│   ├── PlayToEarnNative.sol
│   ├── Ticketing721Native.sol
│   ├── CreatorStreamNative.sol
│   └── PayPerViewNative.sol
│
└── README.md
```

---

## 4. Thiết lập mạng Celo Sepolia trong MetaMask

### Bước 1. Thêm mạng mới

```
Network Name: Celo Sepolia Testnet
RPC URL: https://forno.celo-sepolia.celo-testnet.org
Chain ID: 11142220
Currency Symbol: CELO
Block Explorer: https://celo-sepolia.blockscout.com
```

### Bước 2. Nhận CELO testnet để sử dụng làm gas và thanh toán

Truy cập faucet chính thức:  
https://faucet.celo.org/celo-sepolia

---

## 5. Hướng dẫn triển khai hợp đồng (Cách thủ công – Remix IDE)

1. Mở Remix IDE tại: https://remix.ethereum.org  
2. Kết nối MetaMask và chọn mạng **Celo Sepolia Testnet**  
3. Chuyển sang tab **Deploy & Run Transactions**  
4. Trong phần Environment, chọn **Injected Provider – MetaMask**  
5. Triển khai lần lượt các hợp đồng như sau:

### PlayToEarnNative
- Tham số khởi tạo:
  ```
  rewardPerWin = 100000000000000000   // 0.1 CELO
  minScore = 50
  ```
- Nhấn **Deploy**, xác nhận giao dịch trên MetaMask.

### Ticketing721Native
- Không có tham số khởi tạo.  
- Nhấn **Deploy** và xác nhận.

### CreatorStreamNative
- Không có tham số khởi tạo.  
- Nhấn **Deploy** và xác nhận.

### PayPerViewNative
- Không có tham số khởi tạo.  
- Nhấn **Deploy** và xác nhận.

Sau khi triển khai, Remix sẽ hiển thị địa chỉ hợp đồng tại mục **Deployed Contracts**.

---

## 6. Cách sử dụng và kiểm thử

### 6.1. PlayToEarn (Chơi để nhận thưởng CELO)
- `fund()`: nạp quỹ thưởng CELO vào hợp đồng (nhập Value = 1 CELO trong Remix)
- `play(score)`: người chơi nhập điểm, nếu >= `minScore` sẽ nhận thưởng CELO
- `setParams(newReward, newMinScore)`: thay đổi phần thưởng và độ khó

Ví dụ:
- Gọi `fund()` với Value = 1 CELO  
- Sau đó gọi `play(80)` → người chơi đạt điểm >= 50 nhận 0.1 CELO

---

### 6.2. NFT Ticketing (Vé sự kiện dưới dạng NFT)
- `createEvent(name, priceWei, startTime, maxSupply, lock, baseURI, payout)`  
- `buy(eventId)`: mua vé NFT bằng CELO

Ví dụ:
```
createEvent("Concert", 500000000000000000, 1736000000, 100, true, "ipfs://...", payoutAddress)
```
Người mua nhập Value = 0.5 CELO → gọi `buy(1)` → nhận NFT, tiền được gửi đến ví của nhà tổ chức.

---

### 6.3. Creator Stream (Dòng tiền cho người sáng tạo)
- `createStream(creator, start, end)`: người tài trợ gửi CELO để dòng tiền được phát dần  
- `withdraw(id, amount)`: người sáng tạo rút phần tiền đã tích lũy

Ví dụ:
- Người tài trợ gửi 3 CELO → `createStream(creator, now, now+30days)`  
- Sau vài ngày, người sáng tạo gọi `withdraw(1, 1000000000000000000)` để rút 1 CELO.

---

### 6.4. Pay-per-View (Nội dung trả tiền theo lượt xem)
- `upsertContent(contentId, priceWei, accessWindow, active)`: đăng nội dung mới  
- `buy(contentId)`: người xem mua quyền truy cập bằng CELO  
- `hasAccess(contentId, viewer)`: kiểm tra quyền xem còn hiệu lực

Ví dụ:
```
upsertContent(keccak256("video#1"), 200000000000000000, 86400, true)
```
Người xem gọi `buy(contentId)` với Value = 0.2 CELO → có quyền xem trong 24 giờ.

---

## 7. Kiểm tra giao dịch

Tất cả giao dịch và sự kiện có thể xem tại:  
https://celo-sepolia.blockscout.com

Dán địa chỉ ví hoặc hợp đồng để kiểm tra lịch sử hoạt động.

---

## 8. Mô hình kinh tế (Token Flow)

```
Người chơi / người xem → gửi CELO → Smart Contract → Nhà tổ chức / người sáng tạo nhận CELO
```

Tất cả giao dịch đều được thực hiện trên chuỗi khối Celo, đảm bảo tính minh bạch và truy xuất được.

---

## 9. Bảo mật và mở rộng

- Các hợp đồng sử dụng `ReentrancyGuard` để ngăn tấn công tái nhập.  
- Chỉ sử dụng **CELO gốc**, không phụ thuộc vào token ERC-20.  
- Có thể mở rộng thêm:
  - Cơ chế `Pausable` hoặc `AccessControl` cho quản trị.  
  - Giao diện web bằng React + ethers.js.  
  - Triển khai lại trên **Celo Mainnet** với cùng mã nguồn.

---

## 10. Giấy phép

```
SPDX-License-Identifier: MIT
```

Dự án mã nguồn mở, được phép sử dụng và chỉnh sửa cho mục đích học tập hoặc nghiên cứu.

---

## 11. Tác giả

**Phạm Quang Khải (ka31504)**  
Khoa Công nghệ Thông tin – Đại học Phenikaa  
GitHub: [https://github.com/ka31504](https://github.com/ka31504)  
LinkedIn: [https://linkedin.com/in/khaipham315](https://linkedin.com/in/khaipham315)

