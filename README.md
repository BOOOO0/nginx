# Nginx

- conf 파일을 다뤄서 서로 다른 서브넷에 위치하는 EC2 인스턴스 간 통신이 가능하도록 리버스 프록시를 성공시켜보자.

## [AWS EC2](./EC2/README.md)

- AWS EC2로 구성된 인프라에서 프론트엔드 -> 백엔드 통신

## [AWS EKS](./EKS/README.md)

- 도커 컨테이너에 Nginx conf 파일을 복사해서 설정하고 그 설정을 통해 EKS 클러스터 내 프론트엔드 -> 백엔드 통신
