# Flutter Next Ordering System

주문 시스템 프로젝트 - 서버, 식당용 클라이언트, 모바일 클라이언트를 포함합니다.

## 구조

### Server
- Node.js와 Express를 사용한 백엔드 서버
- 위치: `/server`
- 기술 스택: Node.js, Express, MongoDB, Socket.IO

### Restaurant Client
- 식당용 Flutter 클라이언트
- 위치: `/flutter_client`
- 기술 스택: Flutter, GetX

### Mobile Client
- 고객용 모바일 Flutter 클라이언트
- 위치: `/mobile_client`
- 기술 스택: Flutter, GetX

## 설치 및 실행 방법

### Server
```bash
cd server
npm install
npm start