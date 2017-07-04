# Core_dump
internship project


current reference : http://stackoverflow.com/questions/324704/arm-access-user-r13-and-r14-from-supervisor-mode


https://static.docs.arm.com/ddi0460/d/DDI0460.pdf // 이거 받아서 좀 볼것 (Coprocessor Register 와 Coresight)

http://www.slideshare.net/RaahulRaghavan/arm-cortex-m-bootup-cmsispart33debugarchitecture

//on chip debugging 방식으로 DAP에 접근할수있다는 얘기가 있음 확인할것


http://arttools.blogspot.kr/2009/09/debugging-on-cortex-a8-system.html
//////////// 디버그 유닛 디버그 레지스터




==============================내일 발표할것 멘트

다음 그림은 Register Dump를 위해 이용하려했던 Coresight의 간략한 개요입니다.

Coresight란 ARM SoC 자체에 내장된 디버깅 인터페이스 모듈드로가 서비스를 통칭하는 용어입니다.

이전부터 디버깅 모듈은 존재했으나 기능을 추가하고 이를 통합하여 ARMv7 아키텍쳐부터 Coresight란 명칭이 붙었습니다.

Coresight의 핵심 구성요소로는 가운데있는 DAP 과 여러개의 TM이 있습니다.


DAP의 주 구성요소는 AHB-AP와 APB-AP가 있습니다.

여기의 청색선은 AHB이고 녹색은 APB입니다.

AHB버스를 통해 실시간으로 물리메모리값을 스캔할수있고

APB버스를 통해 각 프로세서와 코프로세서에 접근할 수 있습니다.


하지만 결론적으로 DAP이라는 인터페이스는 JTAG과 같은 외부 디버거를 필요로 하기때문에

내부적인 접근을 위해 다른 방법을 알아보아야 했습니다.

====================================================
#2
다음 그림은 디버그 레지스터를 보여드리기 위해 준비했습니다.

CS의 디버깅 인터페이스 중에는 코어와 연결된 디버그 레지스터가 있습니다.

가이드로 주신 중단된 CS활용 프로젝트의 소스에서 코프로세서로 디버깅 레지스터를 컨트롤하여 레지스터 값을 읽어오는 부분이 잇엇습니다.

그예를 소스를 통해 보시겟습니다.

====================================================
예상질문

AHB와 APB의 차이는?

ETM이 무엇인가? 프로세서가 수행하는 인스트럭션에 대한 트레이스 정보를 출력시켜주는 모듈

FUNNEL이 무엇인가? 여기저기있는 트레이스 매크로셀이 뱉어내는 데이터들을 싱크맞춰 하나의 스트림으로 만들어주는 모듈

ITM?? data값을 호스트에서 printf 처럼 출력시켜주는 모듈

STM??

==================================================== ssd 관련뉴스

1. difference of between client to Ent. - http://2cpu.co.kr/bbs/board.php?bo_table=QnA&wr_id=439537
2. new interface PCIe 5.0 - http://www.tomshardware.com/news/pcie-5.0-release-0.3,34720.html
3. Intel 3D optane ssd DC P4800X - http://www.tomshardware.com/reviews/intel-optane-3d-xpoint-p4800x,5030.html
4. ADATA's Enterprise SSD - http://www.tomshardware.com/news/adata-new-3d-ssd-computex,34657.html
5. micron enterprise ssd - http://www.storagereview.com/micron_5100_max_ssd_review
