# 달베어: 지구를 지켜라
### DALBEAR: Earth Defense · [dalbear.com](https://dalbear.com)

> 달빛을 먹고 자란 곰, **달베어**.
> 외계 함대가 지구를 덮친 밤, 스무 개의 전선을 지켜낸다.

**20개 스테이지 × 4분**, **4단계 난이도**, **53종 외계인 + 25종 중간 보스 + 20종 최종 보스**,
**무기 8종 + 진화 무기 8종**, **인런 유물**, **무한 모드 · 일일 챌린지 · 업적 12종**,
**속성 시너지 · 달빛 제단 · 달빛 동료 5종 · 장비 세트**,
**장비 잠금 · 일괄 분해 · 로드아웃 3칸 · 주간 기록**,
**대시 & 궁극기**, **리롤·밴**, **그래픽 프리셋 · HUD 크기 · 조이스틱 배치**, **연출 설정 · 플랫폼 · 접근성**,
**장비 11슬롯 · 인벤토리 · 등급 · 강화**, **5명의 달베어 친구**,
**8방향 모션**, **자동 저장 & 이어하기**로 구성한 2D 로그라이트 서바이벌입니다.
Godot 4.7.1로 제작했고, 모든 그래픽·사운드는 무료 에셋과 직접 생성한 원화/효과음으로 만들었습니다.

![타이틀](screenshots/title.png)

> **다운로드**: [GitHub Releases](https://github.com/murse2000/DalbearSurvival/releases/latest)  
> Windows 실행 파일과 Android APK를 릴리스에서 받을 수 있습니다.
> 저장소: [github.com/murse2000/DalbearSurvival](https://github.com/murse2000/DalbearSurvival)

---

## 실행 방법

### 1. 빌드된 실행 파일 (Windows 64-bit)
`build/DALBEAR.exe`를 더블클릭합니다.

> **참고**: 코드 서명이 없는 빌드라 Windows SmartScreen이 경고할 수 있습니다.
> "추가 정보" → "실행"을 선택하면 됩니다. (약 114MB, Godot 4.7.1 x86_64)
> 라이선스/문서는 `build/` 폴더에 함께 들어 있습니다.

### 2. Android APK
`build/DALBEAR.apk`를 Android 기기에 설치합니다. (디버그 서명, minSdk 24, arm64-v8a)

```bash
adb install -r build/DALBEAR.apk
```

모바일에서는 가상 조이스틱·대시·궁극기·일시정지 버튼이 자동으로 표시됩니다.

### 3. Godot으로 실행
1. **Godot 4.7.1** 이상을 실행합니다.
2. `project.godot`을 엽니다.
3. `F5`를 누릅니다.
4. 또는 `run_game.bat`을 더블클릭합니다. (Godot 경로가 다르면 bat 파일의 `GODOT_EXE`를 수정)

### 4. 직접 내보내기
```bash
godot --headless --path . --export-release "Windows Desktop" build/DALBEAR.exe
godot --headless --path . --export-debug "Android" build/DALBEAR.apk
```

---

## 조작

| 입력 | 동작 |
|---|---|
| `WASD` / 방향키 | 이동 |
| `Space` / 패드 B | 대시 (짧은 무적 + 이동) |
| `Q` / 패드 Y | 궁극기 **달빛 심판** (킬로 충전) |
| 자동 | 가장 가까운 외계인을 향해 자동 공격 |
| `1` `2` `3` / 마우스 클릭 | 레벨 업 강화 선택 (밴 모드에서는 제외할 카드 선택) |
| `R` | 레벨 업 리롤 (런당 2회) |
| `B` | 레벨 업 밴 모드 (런당 1회, `ESC` 취소) |
| `I` | 타이틀·전선 선택에서 **장비 & 인벤토리** 열기 |
| `C` | 타이틀·전선 선택·장비 화면에서 **친구 선택** 열기 |
| `A` | 전선 선택에서 **업적** 열기 |
| `T` | 전선 선택에서 **달빛 제단** 열기 |
| `ESC` / 패드 START | 일시정지 / 계속하기 / 장비·친구 화면에서 돌아가기 |
| `F11` | 창 모드 / 전체 화면 즉시 전환 |
| **터치** | 왼쪽 가상 조이스틱 이동 · 오른쪽 **대시/궁극기** · 우측 상단 **일시정지** |
| `ENTER` | 타이틀·전선 선택에서 출격, 결과 화면에서 다음 전선/재도전 |
| `1`~`9` `0` / 좌우 스와이프·휠·`Q` `E` / `←` `→` | 전선(1~10) / 페이지 / 난이도 선택 |
| 게임패드 | 스틱/D-PAD 이동 · A 확인 · B 뒤로 · START 일시정지 · 전선 선택에서 D-PAD로 전선/난이도 변경 |

---

## 모바일 & 터치

- 모바일에서는 **플로팅 가상 조이스틱**(왼쪽 아래 기본 위치, 화면 아무 곳이나 터치해 생성), **대시**(오른쪽 아래), **궁극기**(오른쪽 아래), **일시정지**(오른쪽 위)가 자동 표시됩니다.
- 조이스틱은 터치한 위치를 중심으로 생성되며, 대시/궁극기/일시정지 버튼을 제외한 **화면 어느 곳을 눌러도 이동**할 수 있습니다.
- 조이스틱은 멀티터치를 지원해 이동하면서 대시·궁극기를 동시에 누를 수 있습니다.
- 대시/궁극기 버튼에는 각각 **쿨다운·충전량**이 링과 퍼센트로 표시됩니다.
- 타이틀·전선 선택·레벨업·장비·친구·설정 화면은 터치 입력을 그대로 지원합니다.
- **홈 화면/백그라운드 전환 시 자동 일시정지**됩니다. 복귀하면 일시정지 메뉴가 유지되며, `계속하기`를 눌러야 전투가 재개됩니다. 백그라운드 동안 타이머·적·발사체가 진행되지 않고 오디오도 음소거됩니다.
- 데스크톱에서 터치 UI를 확인하려면 `--touch` 인자를 사용합니다.
- Android 설정: **가로·세로 자동 회전(센서)**, 1280×720 기준 `canvas_items` 스트레치, ETC2/ASTC 텍스처 임포트, arm64-v8a.
- 기기를 돌리면 화면이 따라 회전합니다. 전투 HUD·카메라·전선 선택 화면은 새 방향에 맞춰 다시 배치됩니다.
- Android 빌드에는 Godot 4.7.1 Android export template, Android SDK, JDK, 디버그 키스토어가 필요합니다.

### 모바일 설정
설정 화면(타이틀·일시정지)에서 기기에 맞게 조절할 수 있습니다. 세로 화면에서는 설정 패널이 화면 폭에 맞춰 크게 표시됩니다.

| 항목 | 값 | 설명 |
|---|---|---|
| 그래픽 프리셋 | 절전 / 균형 / 고품질 | FX 상한·파티클·라이트·데칼·데미지 숫자·블룸을 한 번에 조절 |
| 전투 HUD 크기 | 작게 / 보통 / 크게 | 타이머·체력·스킬 UI를 0.9× / 1.0× / 1.12×로 확대 |
| 조이스틱 위치 | 왼손 / 오른손 | 조이스틱과 대시·궁극기 버튼의 좌우를 교체 |
| 조이스틱 크기 | 작게 / 보통 / 크게 | 조이스틱·버튼·판정 반경·라벨을 함께 조절 |

- 그래픽 프리셋은 **절전**: FX 80·파티클 55%·라이트 2개·데칼/데미지 숫자 끔, **균형**: FX 160·파티클 85%, **고품질**: FX 260·파티클 100%·라이트 14개 기준입니다. (모바일은 상한을 70%로 낮춥니다.)
- 설정은 즉시 저장되며, 전투 중 바꾸면 HUD·터치 버튼·연출에 바로 반영됩니다.
- 블룸·화면 흔들림·데미지 숫자는 프리셋과 별도로 켜고 끌 수 있습니다.

### 저장 & 이어하기
- 진행 중인 전투는 **8초마다 자동 저장**되고, 홈 화면/백그라운드 전환 시에도 즉시 저장됩니다.
- 앱이 종료되거나 Android가 프로세스를 회수한 뒤 다시 실행하면 타이틀에 **이어하기** 버튼이 표시됩니다.
- 이어하기는 **전선·난이도·생존 시간·레벨·경험치·킬·리롤/밴·무기/패시브/진화·체력·위치·궁극기 충전·보스 체력**을 복원합니다.
- 무한 모드·일일 챌린지도 **모드·일일 변칙·무한 보스 웨이브**까지 함께 복원합니다.
- 업적·누적 킬/보스 격추·최고 기록은 별도 진행도로 저장되어 새 모험을 시작해도 유지됩니다.
- 복원 직후 2초 무적과 함께 주변 적은 새로 생성되며, 저장 시점의 일반 적/발사체/픽업은 복원하지 않습니다.
- **새 모험**을 시작하거나 전선 선택·타이틀·결과 화면으로 이동하면 기존 저장은 삭제됩니다.
- 저장 파일: `user://dalbear_run.cfg` (`%APPDATA%\Godot\app_userdata\DALBEAR- Earth Defense\dalbear_run.cfg`)

### 화면비 대응
- 16:9, 20:9, 21:9, 폴드 내부(약 1.1:1)처럼 화면비가 달라도 **게임 월드는 화면을 가득 채웁니다**.
- HUD는 **화면 가장자리 기준**으로 재배치되어 타이머·킬 수·체력·무기 슬롯·터치 버튼이 화면을 벗어나지 않습니다.
- **타이틀 메인 화면**은 화면 높이에 맞춰 텍스트·버튼 블록이 확대 배치되고, 배경 아트가 풀블리드로 깔립니다.
- 전선 선택·장비·친구 화면은 **1280×720 안전 영역**을 중앙에 두고, 남는 영역은 **풀블리드 블러 배경**으로 채워 검은 레터박스가 생기지 않습니다.
- 일시정지·레벨업·결과 화면은 화면 전체를 어둡게 덮고 패널을 중앙에 배치합니다.
- 폴드 폰의 외부/내부 화면 전환 시 viewport 크기 변경을 감지해 HUD·터치·메뉴 레이아웃을 다시 계산합니다.
- **세로 모드**에서는 전투 카메라가 더 가까이 당겨져 캐릭터가 크게 보이고, HUD도 **1.6~1.75배 확대**되어 타이머·체력·무기 슬롯 글자가 읽힙니다.
- 세로 전선 선택은 **한 화면에 한 전선씩 보이는 대형 카드 캐러셀**로 재배치됩니다.
- 세로 장비 화면은 장착 패널과 인벤토리 패널을 **위아래로 쌓고**, 친구 선택은 **3×2 카드 그리드**로 재배치합니다. 글자 크기는 가로 모드와 같습니다.
- 일시정지·레벨업·결과 화면은 화면 중앙에 유지됩니다.

### 성능
- 적이 많아질수록 무거워지던 구간을 모바일 기준으로 다시 손봤습니다.
- 화면 밖(플레이어 기준 560px 밖)의 적은 추격 이동만 계산하고, 분리·지형 충돌·공격·애니메이션은 **화면에 들어올 때** 시작합니다.
- 적 분리 계산을 **공간 해시 직접 순회**로 바꿔 프레임마다 배열을 새로 만들지 않습니다.
- 공간 해시는 **2프레임마다** 재구축하고, 발사체 궤적은 **2프레임마다** 갱신합니다.
- Android에서는 **블룸 후처리 생략**, 일반 적 그림자·발사체 글로우·정예 포인트 라이트를 끄고, FX/데미지 숫자 상한을 낮췄습니다.
- Android 적 동시 수 상한은 280, 데스크톱은 340입니다. (화면에 보이는 밀도는 거의 같습니다.)
- `--bench-enemies=340`으로 340마리 기준 FPS를 측정할 수 있습니다. (예: `godot --path . res://scenes/main.tscn --rendering-method gl_compatibility -- --stage=dawn --bench-enemies=340`)

---

## 캠페인: 스무 개의 전선

| | 전선 | 테마 | 보스 | 새로운 위협 |
|---|---|---|---|---|
| 1 | **달빛 숲** | 달빛이 내려앉은 지구의 숲 | 정찰 모선 | 젤리 침입자, 정찰 드론, 회색 침략자, 플라즈마 해파리, 전투 로봇 |
| 2 | **군체 분화구** | 추락한 함선과 외계 군체 | **군체 여왕** | 산성 사수(원거리), 자폭 벌레, 땅굴 포식자, 군체 약탈자 |
| 3 | **모선 심장부** | 달을 삼킨 자의 배 | **모선 '달을 삼킨 자'** | 격벽 포탑(레이저), 위상 사냥꾼(순간이동), 분열체, 전투 로봇 |
| 4 | **잿빛 균열** | 재와 용암이 흐르는 균열 | **재의 레비아탄** | 마그마 포식자, 잿불 사수, 용암 거인, 잿빛 마녀 |
| 5 | **달의 뒷면** | 빛이 닿지 않는 월식 | **월식의 군주** | 균열 망령, 심연 나방, 균열 추적자, 별을 삼키는 자 |
| 6 | **붉은 사막** | 모래 폭풍이 삼킨 황야 | **사막의 스콜피온** | 사막 추적자, 모래 사수, 사막 여왕 |
| 7 | **얼어붙은 호수** | 얼음 아래 숨은 빛 | **서리 거인** | 서리 정령, 빙갑 게, 서리 거상 |
| 8 | **독성 수렁** | 숨 쉬는 것도 독이 되는 늪 | **독니 여왕** | 수렁 잠복자, 독나방, 수렁 모체 |
| 9 | **강철 폐허** | 무너진 기계가 다시 걷는 땅 | **폐허의 강철신** | 녹슨 사냥개, 톱니 파수꾼, 강철 집행자 |
| 10 | **달빛 성채** | 달의 성벽이 하늘을 가르는 곳 | **달빛 성채의 군주** | 월광 기사, 별안 현자, 성채 파수병 |
| 11 | **심연 해구** | 아래로 갈수록 빛이 죽는 곳 | **심연 포식자** | 심연 아가리, 심층 유충, 해구 포식자 |
| 12 | **태양 흑점** | 궤도를 삼키는 타오르는 흑점 | **흑점의 군주** | 태양불꽃, 마그마 날개, 흑점 폭군 |
| 13 | **성운 미궁** | 별빛이 길을 접는 미궁 | **미궁의 현자** | 미궁 직조자, 프리즘 눈, 미궁 예언자 |
| 14 | **종말 궤도** | 마지막 궤도가 불타는 곳 | **종말의 궤도신** | 궤도 드론, 공허 절단자, 궤도 파괴자 |
| 15 | **새벽의 문** | 모든 밤이 끝나는 문 | **새벽을 삼킨 자** | 새벽 전령, 빛 포식자, 새벽 세라핌 |
| 16 | **거울 성운** | 빛이 두 갈래로 갈라지는 곳 | **거울의 거신** | 거울 도깨비불, 유리 사냥개, 프리즘 파수꾼 |
| 17 | **시간의 회랑** | 멈춘 밤이 반복되는 회랑 | **시계태엽 예언자** | 시계 나방, 시간 파수병, 시간 포식자 |
| 18 | **별의 무덤** | 꺼진 별들이 잠든 곳 | **별의 장례자** | 성해 유충, 별의 잔해, 성해 수집가 |
| 19 | **달빛 심장** | 달의 심장이 마지막으로 뛰는 곳 | **달의 심장** | 월광 사제, 심장 수호병, 월광 기사단장 |
| 20 | **태초의 새벽** | 모든 시작이 끝나는 새벽 | **태초의 달** | 태초 세라핌, 첫 새벽의 그림자, 새벽의 어머니 |

- 각 전선은 **4분(240초)** 동안 이어집니다. **2분 50초**에 보스가 강림합니다.
- 보스를 격추하면 **즉시 전선 확보**. 시간이 끝날 때까지 버텨도 전선을 지켜냅니다.
- **다음 전선은 이전 전선을 클리어한 경우에만 개방**됩니다. 전선 선택 화면에 LOCK으로 표시됩니다.
- 6~20전선은 HP·피해량·출현 밀도가 단계적으로 상승하고, 보스 체력도 4,800 → 20,000으로 올라갑니다.
- 6~20전선(15개)에는 **새 몬스터 30종 · 새 중간 보스 15종 · 새 최종 보스 15종**과 전용 지형·파괴물·썸네일이 추가됩니다. 전체 캠페인은 **20개 전선 · 최종 보스 20종 · 중간 보스 25종**입니다.
- 20번 전선의 태초의 달을 격추하면 캠페인 최종 엔딩 **“지구를 지켜냈다!”**.
### 16~20 전용 패턴

- **거울의 거신**: 좌우 거울 분신에서 부채꼴 탄막을 퍼붓고, 수렴하는 거울 빔과 소환으로 압박합니다.
- **시계태엽 예언자**: 빠르고 느린 두 속도가 교차하는 시간 왜곡 탄막, 시계추 빔, 소환 공격을 사용합니다.
- **별의 장례자**: 하늘에서 별비를 쏟아붓고, 성해를 소환해 전장을 뒤덮습니다.
- **달의 심장**: 예고된 심장 박동 충격파와 굵은 심장 빔으로 근접과 원거리를 동시에 압박합니다.
- **태초의 달**: 사방으로 퍼지는 태초의 심판 탄막, 빔, 소환을 조합한 최종전 패턴을 사용합니다.
- 중간 보스는 각각 **프리즘 파수꾼**(거울 분열+순간이동), **시간 포식자**(시간 왜곡+순간이동), **성해 수집가**(별비+소환), **월광 기사단장**(심장 박동+순간이동), **새벽의 어머니**(슬램+소환)입니다.

### 난이도

| 난이도 | 적 체력 | 적 피해 | 출현 빈도 | 보스 체력 | 경험치 | 정예 출현 |
|---|---|---|---|---|---|---|
| 달빛 (EASY) | ×0.80 | ×0.70 | ×1.20 (느림) | ×0.80 | ×1.25 | 1.5% |
| 표준 (NORMAL) | ×1.00 | ×1.00 | ×1.00 | ×1.00 | ×1.00 | 2.8% |
| 어둠 (HARD) | ×1.35 | ×1.25 | ×0.85 (빠름) | ×1.35 | ×0.95 | 4.5% |
| 심연 (NIGHTMARE) | ×1.75 | ×1.55 | ×0.70 (매우 빠름) | ×1.80 | ×0.85 | 7.0% |

전선 선택 화면에서 난이도를 언제든 바꿀 수 있습니다. 기록은 **전선 × 난이도**별로 저장됩니다.
전선 카드는 **좌우 스와이프**(마우스 드래그·터치), 마우스 휠, `Q`/`E`, 양끝 화살표로 넘길 수 있습니다.

---

## 무한 모드 & 일일 챌린지

### 무한 모드
- **20전선을 완료하면 해금**됩니다. 이전 버전의 진행 세이브도 그대로 이용할 수 있습니다. 전선 선택 화면의 **무한 모드** 버튼으로 진입합니다.
- 4분 제한 없이 계속 싸웁니다. **240초부터 적 체력·피해량·출현 밀도가 계속 상승**합니다.
- 첫 보스는 170초, 이후 **약 90초마다 보스가 다시 강림**하며 웨이브마다 체력·피해량이 증가합니다.
- 160초 이후에는 중간 보스도 **75초 주기**로 등장합니다.
- HUD 타이머가 남은 시간 대신 **생존 시간**을 표시하고, 결과 화면에 생존 시간·킬·전선별 최고 기록이 나옵니다.
- 무한 모드에서도 유물·레벨업·장비 보상은 그대로 적용됩니다.

### 일일 챌린지
- **오늘의 날짜 시드**로 전선·난이도·변칙이 고정됩니다. 같은 날에는 누구나 같은 조합입니다.
- 전선 선택 화면의 **오늘의 도전** 버튼으로 바로 시작합니다. (전선 선택 상태와 무관)
- 변칙 6종: **떼몰이**(출현 +25%), **중갑**(체력 +20%), **광란**(이동 +15%),
  **유리 대포**(피해 +20% · 체력 -10%), **자력 왜곡**(자력 -30), **정예 출현**(정예 +4%).
- 결과 화면에 오늘의 최고 시간·킬·클리어 횟수가 표시되고, 날짜별 기록이 저장됩니다.

### 업적
전선 선택 화면의 **업적** 버튼(또는 `A`)에서 12종 업적과 진행도를 확인할 수 있습니다.
달성 즉시 상단 알림이 뜨고 자동 저장됩니다. 오래된 세이브도 보유 기록을 기준으로 즉시 판정됩니다.

| 업적 | 조건 |
|---|---|
| 첫 새벽 | 첫 전선 클리어 |
| 지구 방위 | 20전선 완주 |
| 사냥꾼 | 누적 1,000킬 |
| 학살자 | 누적 10,000킬 |
| 보스 헌터 | 보스 10회 격추 |
| 한계 돌파 | 한 런 Lv.30 |
| 완전체 | 한 런 무기 8개 진화 |
| 유물 수집가 | 한 런 유물 3개 |
| 전설의 장비 | 전설 등급 장비 장착 |
| 무한의 끝 | 무한 모드 10분 생존 |
| 오늘의 영웅 | 일일 챌린지 클리어 |
| 단련 | 장비 Lv.5 강화 |

### 속성 시너지
무기마다 **불·서리·감전·공허** 속성이 붙고, 적에게 상태를 남깁니다.

| 속성 | 상태 | 효과 |
|---|---|---|
| 불 | 화상 | 3초 동안 지속 피해 |
| 서리 | 둔화 | 3초 동안 이동 속도 -30% |
| 감전 | 감전 | 시너지 매개 |
| 공허 | 균열 | 3초 동안 받는 피해 +25% |

서로 다른 두 속성이 겹치면 적 위에 시너지 이름이 뜨고 주변에 폭발이 일어납니다.

| 조합 | 시너지 | 효과 |
|---|---|---|
| 불 + 서리 | 열충격 | 주변 92px 폭발 |
| 불 + 감전 | 과부하 | 주변 105px 폭발 |
| 서리 + 감전 | 감전 | 주변 86px 연쇄 |
| 불 + 공허 | 소멸 | 주변 110px 강타 |
| 서리 + 공허 | 균열 | 주변 88px 폭발 |
| 감전 + 공허 | 붕괴 | 주변 100px 폭발 |

### 달빛 제단 & 동료
전선 선택의 **달빛 제단** 버튼(또는 `T`)에서 달빛 조각으로 영구 강화를 구매합니다.

| 강화 | 효과 | 최대 |
|---|---|---|
| 달빛 생명 | 최대 체력 +6 | 10 |
| 달빛 분노 | 피해 +3% | 10 |
| 달빛 걸음 | 이동 속도 +2% | 8 |
| 달빛 자력 | 자력 범위 +8 | 8 |
| 달빛 지혜 | 경험치 +3% | 8 |
| 달빛 행운 | 치명타 +1% | 8 |
| 달빛 동료 | 동료 5종 해금 · 공격력/속도 증가 | 5 |

- 제단 강화는 모든 모험에 영구 적용되며 저장됩니다.
- **달빛 동료** 레벨이 오르면 동료가 해금되고 공격력·공격 주기가 좋아집니다. 제단 화면의 **동료 도감**에서 동행할 동료를 선택합니다.

| 제단 Lv | 해금 동료 | 능력 |
|---|---|---|
| 1 | 별이 | 가장 가까운 적에게 달빛 광선 |
| 2 | 서리 | 두 적을 얼려 이동 둔화 |
| 3 | 잿불 | 작은 불꽃 폭발로 화상 |
| 4 | 그림자 | 공허 단검 치명타 |
| 5 | 달 | 주기적 치유 + 약한 빛 공격 |

- 동료는 모든 런에 한 명만 동행하며, 선택은 저장됩니다.
- 동료의 공격에도 속성이 붙어 시너지에 기여합니다.

### 장비 세트 효과
친구 전용 장비 3종을 모두 갖추면 **2세트/3세트 효과**가 추가로 발동합니다. 장비 상세 화면에 현재 세트 진행도가 표시됩니다.

| 세트 | 2세트 | 3세트 |
|---|---|---|
| 달빛 수호 (달) | 최대 체력 +20 | 피해 +8% |
| 별빛 추적 (별) | 공격 대기 -6% | 치명타 +8% |
| 서리 방벽 (서리) | 방어 +2 | 최대 체력 +30 |
| 잿불 사냥 (잿불) | 피해 +8% | 공격 대기 -6% |
| 그림자 춤 (그림자) | 이동 속도 +5% | 치명타 +10% |

---

## 성장과 전투

### 목표
- 외계인을 쓰러뜨리면 경험치 젬이 떨어집니다. 자력 범위 안에 들어오면 빨려옵니다.
- 레벨 업마다 **3개의 강화 카드** 중 하나를 고릅니다.
- **리롤 2회 · 밴 1회**가 런마다 주어집니다. 카드 아래 버튼 또는 `R` / `B`로 사용합니다.
- 무기 8종 × 최대 6레벨, 패시브 8종 × 최대 5레벨.
- 레벨업 필요 경험치는 레벨이 오를수록 **비선형으로 크게 증가**합니다. (Lv.10 165 · Lv.20 428 · Lv.30 768)
- 적 출몰량은 이전 버전보다 **1.5배** 증가했습니다. 대신 무기 4종이 새로 추가되어 대응 선택지가 늘었습니다.
- 모든 강화가 끝나면 회복/경험치/필살기 카드가 등장합니다.

### 리롤 & 밴
- **리롤 (R / 버튼)**: 현재 3장의 강화 카드를 다시 뽑습니다. 진화 카드가 조건을 충족했다면 리롤 후에도 확정 등장합니다.
- **밴 (B / 버튼)**: 제외할 카드를 고르는 모드로 들어갑니다. 카드가 붉게 변하고, 한 장을 선택하면
  그 무기/패시브는 **이번 런에서 다시 등장하지 않습니다** (진화 카드도 함께 제외). `ESC`로 취소할 수 있습니다.
- 밴은 레벨 업 선택을 소모하지 않으며, 제외 후 즉시 새로운 3장이 제시됩니다.
- 남은 리롤/밴 횟수는 레벨 업 화면 하단에 표시됩니다.

### 무기
| 무기 | 특징 |
|---|---|
| **달빛 탄환** | 가장 가까운 적을 자동 추적. 레벨 업 시 탄환 수·관통 증가 |
| **위성 드론** | 곰 주위를 도는 위성. 접촉한 적을 연속 절단 |
| **문 펄스** | 주변 적을 밀쳐내는 광역 충격파 |
| **성광 레이저** | 일직선상의 모든 적을 관통하는 빔 |
| **유성 낙하** | 적 밀집 지역에 유성을 소환. 다중 낙하·잔불 폭발 |
| **성운 연쇄** | 적들 사이를 튕기는 연쇄 번개. 다중 줄기·감전 |
| **월식 특이점** | 적을 끌어당기는 소형 월식. 붕괴 폭발로 마무리 |
| **월광 칼날** | 주위를 회전하는 달빛 칼날 + 주기적 원형 참격파 |

### 무기 진화 (6Lv + 패시브 3Lv)
무기를 6레벨까지 올리고 지정 패시브를 3레벨까지 올리면, 다음 레벨 업에서
**진화 카드가 확정적으로 등장**합니다. 진화한 무기는 HUD에 ★로 표시됩니다.

| 조합 | 진화 무기 | 효과 |
|---|---|---|
| 달빛 탄환 6 + 에너지 코어 3 | **월광 포격** | 유성 달빛 3발이 적 무리를 폭격 |
| 위성 드론 6 + 냉각 장치 3 | **궤도 위성군** | 위성 6기 + 주기적 연쇄 감전 |
| 문 펄스 6 + 합금 외피 3 | **중력 붕괴** | 적을 끌어당긴 뒤 대폭발 |
| 성광 레이저 6 + 행운의 별 3 | **성운 절단** | 3갈래 관통 성운 빔 |
| 유성 낙하 6 + 자력 코일 3 | **은하 유성우** | 보랏빛 유성 5발 + 끌어당김 + 잔불 |
| 성운 연쇄 6 + 나노 재생 3 | **생명 회로** | 초록 연쇄 감전 + 적중 시 체력 회복 |
| 월식 특이점 6 + 제트 부츠 3 | **특이점 질주** | 특이점이 적을 향해 질주 후 붕괴 |
| 월광 칼날 6 + 곰의 심장 3 | **월광 회오리** | 칼날 7개 + 참격파 체력 회복 |

조건을 충족하면 화면에 진화 힌트가 표시되고, 일시정지 화면에도 규칙이 나옵니다.

### 인런 유물
- 전선에 입장하면 **45초·100초·155초**에 유물 3개 중 1개를 선택합니다. (게임 일시정지)
- 유물은 그 런에서만 유지되고, 체크포인트 저장·이어하기에도 포함됩니다.
- 능력치형 유물은 장단점이 함께 있습니다. 예: 달의 심장(피해 +25%, 최대 체력 -20), 밤의 장막(방어 +3, 이동 -8%).
- 특수형: **불굴의 심장**(치명적 피해 1회 무효), **달빛 렌즈**(경험치 +20%).
- 보유 유물은 일시정지 화면에 이름으로 표시되고, 획득 시 상단에 알림이 뜹니다.

### 중간 보스
- 각 전선 **1분 10초 / 2분 15초**에 맵 전용 중간 보스가 출현합니다.
- 달빛 숲: **고목 수호자**(슬램) → **월식 추적자**(돌진)
- 군체 분화구: **포자 모체**(소환·산성) → **군체 폭군**(슬램)
- 모선 심장부: **격벽 파괴자**(레이저) → **공허 사냥꾼**(순간이동·탄막)
- 중간 보스는 하단 보스 바에 이름과 체력이 표시되며, 처치 시 다량의 경험치와 회복 아이템을 떨어뜨립니다.

### 파괴 가능 지형
- 맵마다 **이동을 막는 파괴 가능 오브젝트**가 배치됩니다.
- 달빛 숲: 고목·바위·외계 수정 / 군체: 알·포자 주머니·산호 / 모선: 캡슐·콘솔·격벽
- 일반 이동은 지형을 통과하지 못하고, 적도 지형에 막혀 우회합니다.
- **대시**, 모든 무기, 유성/연쇄/특이점/칼날, 궁극기, 발사체로 파괴할 수 있습니다.
- 수정·알·캡슐은 파괴 시 주변에 **파편·산성·전격 폭발**을 일으키고 경험치를 떨어뜨립니다.

### 크리티컬 & 콤보
- 크리티컬 발생 시 **대형 붉은 CRIT! 텍스트, 붉은 충격파·파티클·화면 플래시·라이트 버스트**가 터집니다.
- 콤보 카운터는 화면 상단이 아니라 **캐릭터 바로 위/옆을 따라다니며**, 처치할 때마다 **팍팍 튀는 스케일 애니메이션**과 작은 링 파티클이 발생합니다.
- 10/25/50/100 콤보 마일스톤은 캐릭터 인근에서 배너와 대형 버스트로 표시됩니다.

### 8방향 모션
- 정면·후면·좌우에 더해 **정면 대각선·후면 대각선** 스프라이트를 추가했습니다.
- 대각선은 기울임 변형이 아니라 **3/4 시점 전용 포즈를 직접 작도**했습니다. (얼굴·어깨·스카프·제트팩이 대각선 방향으로 돌아감)
- 대각선 이동 시 3/4 시점 프레임과 좌우 반전을 사용해 8방향 이동이 자연스럽게 보입니다.

### 대시 & 궁극기
- **대시 (Space / 패드 B)**: 0.16초 동안 빠르게 이동하며 무적. 쿨다운 2초. 잔상과 파티클이 남습니다.
- **궁극기 (Q / 패드 Y) — 달빛 심판**: 적을 처치할 때마다 충전(킬당 +1.6, 최대 100).
  발동하면 주변 470px에 180 피해, 6개의 추가 유성 폭격, 적 탄환 소거, 1.3초 무적을 얻습니다.
- 하단 HUD의 두 슬롯에서 대시 쿨다운과 궁극기 충전을 확인할 수 있습니다. 충전이 가득 차면 궁극기 슬롯이 금색으로 빛납니다.

### 패시브
제트 부츠(이동), 에너지 코어(피해), 냉각 장치(공격 속도), 곰의 심장(최대 체력),
자력 코일(획득 범위), 행운의 별(치명타), 합금 외피(방어), 나노 재생(회복).

### 외계인 공격 패턴
- **산성 사수**: 거리를 유지하며 2~3발의 산성탄을 부채꼴로 발사
- **자폭 벌레**: 접근 후 0.9초 점화, 주변에 광역 폭발
- **땅굴 포식자**: 땅속으로 잠수해 무적 상태로 이동한 뒤 플레이어 발밑에서 솟아오름
- **군체 약탈자**: 느리지만 단단하고, 돌진 전조 후 4배속으로 돌진
- **격벽 포탑**: 0.85초 조준선을 보여준 뒤 레이저 발사
- **위상 사냥꾼**: 주기적으로 플레이어 옆으로 순간이동
- **분열체**: 사망 시 2마리의 분열 조각으로 분열
- **군체 여왕**: 산성 부채꼴, 소환, 바닥 슬램(전조 원), 40% 이하 폭주
- **모선**: 방사형 탄막, 나선 탄막, 소환, 조준 레이저, 40% 이하 폭주

### 화려한 이펙트
- **Lit - 2D Lighting Engine** 기반 2D 광원: 플레이어 **후광/림라이트**, 적·보스 조명, 맵 오브젝트의 색 광원, 폭발·궁극기 라이트 버스트
- **캐릭터 자기 발광 분리**: 플레이어 라이트는 주변/적만 비추고 캐릭터는 뒤에서 비추는 실루엣·림으로 처리해 얼굴이 하얗게 날아가지 않음
- 풀스크린 **블룸**, 색수차, 임팩트 왜곡, 필름 그레인, 비네트 (커스텀 셰이더)
- 적중/사망/폭발/픽업/레벨 업마다 **파티클 폭발 + 충격파 + 플래시**
- 투사체 빛 궤적, 레이저 전격 아크, 보스 등장 빔, 보스 사망 연쇄 폭발 + 슬로우 모션
- **대시 잔상 · 궁극기 달빛 심판 · 6연속 유성 폭격**
- 신규 스킬 전용 연출: **유성 궤적·충격 화염**, **연쇄 번개 아크**, **월식 블랙홀·붕괴 플래시**, **회전 칼날·원형 참격파**
- **콤보 시스템**: 연속 처치 시 화면 중앙 콤보 카운터, 10/25/50/100/150/200 콤보 마일스톤 버스트, 콤보 색상 변화
- **히트스톱 · 화면 충격 줌 · 방사형 속도선 · 채도 펄스**로 강한 타격감
- **궁극기/보스 격추 시 화면 왜곡·속도선·대형 플래시·슬로우 모션**
- 화면 흔들림, 카메라 펀치 줌, 보스전 카메라 프레이밍
- Kenney CC0 파티클 텍스처 + 직접 만든 픽셀아트/글로우

### 플랫폼 & 접근성
- 타이틀 화면의 **설정** 버튼 또는 일시정지 메뉴의 **설정**에서 **화면 / 조작 / 접근성** 탭을 이용할 수 있습니다.
- **화면**: 창 모드(창 · 테두리 없음 · 전체 화면), VSync, FPS 제한(60 · 120 · 144 · 무제한), 그래픽 품질, HUD 크기. `F11`로 전체 화면을 즉시 전환합니다.
- **조작**: 키보드·마우스와 게임패드(스틱/D-PAD · A · B · START)를 함께 지원합니다. 전선 선택에서 D-PAD로 전선과 난이도를 바꿀 수 있고, Android 뒤로가기는 설정 닫기 → 일시정지 → 전선 선택 순으로 동작합니다.
- **접근성**: 화면 플래시(끔 · 약하게 · 보통), 모션 강도(끔 · 약하게 · 보통), 색약 팔레트(녹색약 · 적색약 · 청색약), 고대비 적 탄막 외곽선을 제공합니다.
- **포커스 상실 시 자동 일시정지**를 켜거나 끌 수 있습니다.
- 변경 사항은 즉시 적용되고 자동 저장되어 다음 실행에도 유지됩니다. 밝은 화면이 부담스럽거나 피격 연출을 줄이고 싶을 때 사용하세요.

---

## 달베어의 친구들

타이틀·전선 선택 화면의 **친구들** 버튼(단축키 `C`)에서 다섯 친구 중 한 명을 선택합니다.
친구마다 기본 능력치·특성·전용 장비 세트가 다르며, 전투 중 스프라이트와 오라·대시·궁극기 색도 달라집니다.

| 친구 | 특성 | 전투 스타일 | 전용 장비 |
|---|---|---|---|
| **달베어** | 달빛의 가호 · 방어 +1 | 균형 잡힌 올라운더 | 달빛 성검 · 달빛 수호 갑주 · 달빛 성흔 |
| **별곰** | 별빛 집중 · 공격 대기 -12%, 피해 +12%, 체력 -14% | 빠른 원거리 화력 | 별의 지팡이 · 별빛 로브 · 별의 반지 |
| **서리곰** | 서리 갑주 · 방어 +2.5, 체력 +30%, 이동 -8% | 느리지만 단단한 탱커 | 서리 도끼 · 빙하 갑주 · 서리 심장 |
| **불꽃곰** | 불씨 · 피해 +18%, 이동 +7%, 체력 -8% | 빠르게 파고드는 돌격형 | 화염 창 · 불꽃 장갑 · 잿불 반지 |
| **그림자곰** | 그림자 보법 · 대시 쿨다운 -35%, 치명타 +5%, 체력 -16% | 대시와 치명타 위주의 회피형 | 그림자 단검 · 밤그늘 망토 · 달그림자 반지 |

- 모든 친구는 처음부터 선택할 수 있습니다.
- 친구를 선택하면 그 친구의 **전용 장비 3종**이 인벤토리에 추가됩니다. 현재 장비보다 강하면 자동 장착됩니다.
- 전용 장비는 **해당 친구만 장착**할 수 있고, 분해할 수 없습니다. 강화는 가능합니다.
- 다른 친구의 전용 장비는 인벤토리에서 흐리게 표시되고, 상세 화면에 전용 친구가 표시됩니다.
- 친구를 바꾸면 이전 친구의 전용 장비는 자동 해제되고, 비어 버린 슬롯은 보유한 일반 장비로 채워집니다.
- 친구별로 시작 무기·대시 쿨다운·체력·피해·치명타·재생·자력 범위가 다릅니다.

---

## 장비 & 인벤토리

타이틀 또는 전선 선택 화면의 **장비** 버튼(단축키 `I`)에서 장비를 관리합니다.
캐릭터를 가운데 두고 방어구·무기·악세서리 슬롯이 주변에 배치되며,
오른쪽은 아이콘 격자 인벤토리입니다. 장비는 런이 끝날 때마다 **달빛 조각**과 함께 획득하며, 다음 런부터 능력치가 적용됩니다.

### 11개 슬롯

| 분류 | 슬롯 |
|---|---|
| 방어구 (6) | 헬멧 · 장갑 · 흉갑 · 각반 · 부츠 · 망토 |
| 무기 (2) | 주 무기 · 보조 무기 |
| 악세서리 (3) | 반지 I · 반지 II · 목걸이 |

- **주/보조 무기**로 장착한 무기는 런 시작 시 해당 무기로 시작합니다. 같은 무기 종류를 두 슬롯에 동시에 장착할 수 없습니다.
- 무기 장비 레벨이 오르면 **시작 무기 레벨**도 함께 오릅니다 (4레벨마다 +1, 최대 4).
- 방어구와 악세서리는 체력·방어·피해·공격 대기·이동·치명타·자력·재생 등을 올립니다.
- **전용 장비**(친구 서명 장비)는 일반 장비보다 강한 고유 능력치를 가지며, 지정된 친구만 장착할 수 있습니다.
- 장비 화면 상단의 **친구들** 버튼 또는 `C`로 친구를 바꿀 수 있습니다.
- 인벤토리 아이템을 **슬롯 위로 끌어다 놓아 장착**할 수 있습니다. 마우스 드래그와 터치 스와이프 모두 지원하며, 캐릭터 위에 놓으면 알맞은 빈 슬롯에 자동으로 들어갑니다.
- 인벤토리 상단의 **최적 장착** 버튼 하나로 보유한 가장 강한 장비를 11개 슬롯에 자동 장착합니다. (전용 장비는 해당 친구만, 같은 무기 종류 중복 없음)
- 아이콘 왼쪽 위의 **타입 배지**(헬/장/흉/각/부/망/무/반/목)와 하단 **등급 띠**(일반/희귀/에픽/전설)로 종류와 등급을 한눈에 구분합니다.
- 장착 중인 아이템은 **금색 테두리와 ✓ 표시**로 구분됩니다.
- **전설** 등급 아이템은 인벤토리·슬롯·상세에서 금색 글로우가 맥동합니다.
- 상세 패널에서 현재 장착된 아이템과 비교해 능력치 증감을 **초록(+)/빨강(-)**으로, 전투력 변화까지 함께 보여줍니다.

### 장비 QoL
- **잠금**: 상세 패널의 잠금 버튼으로 아이템을 잠급니다. 잠근 아이템은 분해·일괄 분해에서 제외되며 인벤토리에 `잠` 표시가 붙습니다.
- **일괄 분해**: 인벤토리의 일괄 분해 버튼으로 **일반·희귀** 등급을 한 번에 분해합니다. 장착 중·잠금·전용 장비·에픽 이상은 자동 제외되고, 실행 전 대상 수와 예상 달빛 조각을 보여줍니다.
- **로드아웃 3칸**: 현재 장착 11슬롯을 저장하고 불러올 수 있습니다. 친구별 로드아웃이며, 없는 장비는 건너뜁니다.

### 주간 기록
- 전선 선택의 **주간 기록** 버튼에서 이번 주 최고 기록을 확인합니다.
- 전선 최고 생존 시간·킬·클리어, 무한 최고 생존·킬, 일일 클리어·최고 시간, 주간 도전 횟수·누적 킬을 저장합니다.
- 매주 월요일 초기화되며, 이전 주 기록은 새 주가 시작될 때 비워집니다.

### 등급과 레벨

| 등급 | 색상 | 최대 레벨 | 기본 능력치 |
|---|---|---|---|
| 일반 | 회색 | 5 | ×1.00 |
| 희귀 | 파랑 | 10 | ×1.32 |
| 에픽 | 보라 | 15 | ×1.72 |
| 전설 | 금색 | 20 | ×2.25 |

- 모든 장비는 **Lv.1부터 시작**하며, 레벨이 오를 때마다 능력치가 상승합니다.
- **강화**는 달빛 조각을 소비해 장비 레벨을 올립니다. 등급이 높을수록 최대 레벨과 강화 비용이 큽니다.
- 인벤토리에서 **분해**하면 달빛 조각을 일부 돌려받습니다. 장착 중인 장비는 분해할 수 없습니다.
- 장비는 **슬롯 · 등급 · 레벨 · 무기 종류 · 고유 UID**로 저장되어 다음 실행에도 유지됩니다.

### 보상 루프
- 런 종료 시 생존 시간·킬·승리·보스 격추에 따라 **달빛 조각**을 얻습니다.
- 같은 조건으로 **장비 1~3개**를 획득합니다. 승리와 보스 격추, 높은 난이도/전선일수록 드롭 등급이 좋아집니다.
- 장비 화면에서 부위 필터, 장착, 강화, 분해를 반복하며 빌드를 완성하세요.
- 시작 세트: 일반 등급 11부위 + 달빛 조각 150개.

---

## 스크린샷

| | |
|---|---|
| ![전선 선택](screenshots/stage_select.png) | ![군체 분화구](screenshots/stage_hive.png) |
| ![모선 심장부](screenshots/stage_ship.png) | ![군체 여왕](screenshots/queen.png) |
| ![모선 보스전](screenshots/boss.png) | ![최종 엔딩](screenshots/final_clear.png) |
| ![무기 진화](screenshots/evolution.png) | ![진화 전투](screenshots/evolution_gameplay.png) |
| ![Lit 2D 조명](screenshots/lighting.png) | ![신규 스킬](screenshots/new_skills.png) |
| ![중간 보스·지형](screenshots/world_expansion.png) | ![게임플레이](screenshots/gameplay.png) |
| ![유물 선택](screenshots/relics.png) | ![대각선 이동](screenshots/diagonal.png) |
| ![크리티컬](screenshots/crit.png) | ![잿빛 균열](screenshots/stage_crater.png) |
| ![달의 뒷면](screenshots/stage_void.png) | ![50 콤보](screenshots/combo.png) |
| ![대시·궁극기](screenshots/abilities.png) | ![리롤·밴 카드](screenshots/levelup.png) |
| ![밴 모드](screenshots/banish.png) | ![모바일 설정](screenshots/settings.png) |
| ![세로 설정](screenshots/settings_portrait.png) | ![일시정지 설정](screenshots/pause_settings.png) |
| ![오른손·큰 조이스틱](screenshots/touch_gameplay.png) | ![세로 오른손 조작](screenshots/touch_gameplay_portrait.png) |
| ![장비 & 인벤토리](screenshots/equipment.png) | ![장비 상세](screenshots/equipment_detail.png) |
| ![일괄 분해](screenshots/gear_bulk.png) | ![로드아웃](screenshots/gear_loadout.png) |
| ![주간 기록](screenshots/weekly.png) | ![세로 주간 기록](screenshots/weekly_portrait.png) |
| ![친구 선택](screenshots/characters.png) | ![와이드 터치](screenshots/gameplay_wide.png) |
| ![폴드 비율](screenshots/gameplay_fold.png) | ![타이틀 와이드](screenshots/title_wide.png) |
| ![타이틀 폴드](screenshots/title_fold.png) | ![이어하기](screenshots/title_continue.png) |
| ![20개 전선 선택](screenshots/stage_select_late.png) | ![붉은 사막](screenshots/stage_dunes.png) |
| ![얼어붙은 호수](screenshots/stage_frost.png) | ![독성 수렁](screenshots/stage_mire.png) |
| ![강철 폐허](screenshots/stage_ruins.png) | ![달빛 성채](screenshots/stage_citadel.png) |
| ![심연 해구](screenshots/stage_trench.png) | ![태양 흑점](screenshots/stage_sunspot.png) |
| ![성운 미궁](screenshots/stage_maze.png) | ![종말 궤도](screenshots/stage_orbit.png) |
| ![새벽의 문](screenshots/stage_dawn.png) | ![사막의 스콜피온](screenshots/boss_dunes.png) |
| ![세로 타이틀](screenshots/title_portrait.png) | ![세로 전선 선택](screenshots/stage_select_portrait.png) |
| ![세로 전투](screenshots/stage_dunes_portrait.png) | ![세로 장비](screenshots/equipment_portrait.png) |
| ![세로 친구 선택](screenshots/characters_portrait.png) | ![20개 전선 선택](screenshots/stage_select_late.png) |
| ![거울 성운](screenshots/stage_mirror.png) | ![태초의 달](screenshots/boss_genesis.png) |
| ![업적](screenshots/achievements.png) | ![세로 업적](screenshots/achievements_portrait.png) |
| ![달빛 제단](screenshots/altar.png) | ![세로 달빛 제단](screenshots/altar_portrait.png) |
| ![달빛 동료 도감](screenshots/companions.png) | ![세로 동료 도감](screenshots/companions_portrait.png) |
| ![달빛 동료](screenshots/companion.png) | ![속성 전투](screenshots/gameplay.png) |
| ![무한 모드](screenshots/endless.png) | ![일일 챌린지](screenshots/daily.png) |
| ![무한 모드 결과](screenshots/endless_end.png) | ![전선 선택](screenshots/stage_select.png) |
| ![일일 도전 확인](screenshots/daily_modal.png) | ![세로 일일 도전](screenshots/daily_modal_portrait.png) |

추가 캡처: `screenshots/gameplay.png`, `screenshots/levelup.png`, `screenshots/pause.png`,
`screenshots/stage_clear.png`, `screenshots/defeat.png`, `screenshots/equipment.png`,
`screenshots/equipment_detail.png`, `screenshots/characters.png`, `screenshots/rewards.png`,
`screenshots/gameplay_wide.png`, `screenshots/gameplay_fold.png`, `screenshots/title_wide.png`,
`screenshots/title_fold.png`, `screenshots/title_continue.png`, `screenshots/new_skills.png`,
`screenshots/lighting.png`, `screenshots/world_expansion.png`, `screenshots/combo.png`,
`screenshots/crit.png`, `screenshots/stage_crater.png`, `screenshots/stage_void.png`,
`screenshots/diagonal.png`, `screenshots/relics.png`,
`screenshots/achievements.png`, `screenshots/achievements_portrait.png`,
`screenshots/altar.png`, `screenshots/altar_portrait.png`,
`screenshots/companions.png`, `screenshots/companions_portrait.png`,
`screenshots/companion.png`,
`screenshots/gear_bulk.png`, `screenshots/gear_loadout.png`,
`screenshots/weekly.png`, `screenshots/weekly_portrait.png`,
`screenshots/settings.png`, `screenshots/settings_portrait.png`,
`screenshots/touch_gameplay.png`, `screenshots/touch_gameplay_portrait.png`,
`screenshots/endless.png`, `screenshots/daily.png`, `screenshots/endless_end.png`,
`screenshots/daily_modal.png`, `screenshots/daily_modal_portrait.png`,
`screenshots/stage_select_late.png`, `screenshots/stage_dunes.png`, `screenshots/stage_frost.png`,
`screenshots/stage_mire.png`, `screenshots/stage_ruins.png`, `screenshots/stage_citadel.png`,
`screenshots/stage_trench.png`, `screenshots/stage_sunspot.png`, `screenshots/stage_maze.png`,
`screenshots/stage_orbit.png`, `screenshots/stage_dawn.png`, `screenshots/boss_dunes.png`,
`screenshots/stage_mirror.png`, `screenshots/boss_genesis.png`,
`screenshots/title.png`

---

## 프로젝트 구조

```
DalbearSurvival/
├─ project.godot                 # Godot 4.7.1 프로젝트 설정
├─ scenes/
│  ├─ title.tscn                 # 타이틀
│  ├─ stage_select.tscn          # 20개 전선 + 4개 난이도 선택
│  ├─ equipment.tscn             # 장비 & 인벤토리 화면
│  ├─ characters.tscn            # 달베어 친구 선택
│  ├─ achievements.tscn          # 업적 보드
│  ├─ altar.tscn                 # 달빛 제단
│  ├─ companions.tscn            # 동료 도감
│  ├─ main.tscn / player.tscn / enemy.tscn
├─ scripts/
│  ├─ game_data.gd               # 20개 전선/난이도/무기/적/보스/패시브/일일 변칙 데이터
│  ├─ achievement_data.gd        # 업적 12종 정의/진행도
│  ├─ achievements_screen.gd     # 업적 보드 UI
│  ├─ altar_data.gd              # 제단 영구 강화 7종
│  ├─ altar_screen.gd            # 제단 UI
│  ├─ companion.gd               # 달빛 동료 행동
│  ├─ companion_data.gd          # 동료 5종 정의
│  ├─ companion_screen.gd        # 동료 도감 UI
│  ├─ character_data.gd          # 친구 5명 능력치/특성/전용 장비
│  ├─ character_select.gd        # 친구 선택 UI
│  ├─ equipment_data.gd          # 장비 등급/슬롯/능력치/강화 계산
│  ├─ equipment_screen.gd        # 장비 장착/필터/강화/분해 UI
│  ├─ player.gd                  # 이동, 체력, 강화, XP, 장비/친구 스탯
│  ├─ enemy.gd                   # 외계인 AI, 중간 보스/최종 보스 패턴
│  ├─ enemy_manager.gd           # 스테이지 스폰, 전용 파괴물, 공간 해시, 판정
│  ├─ world.gd                   # 20개 전선 테마/지형/프롭
│  ├─ stage_select.gd            # 캠페인 허브 UI
│  ├─ weapons/                   # 4개 무기 + 베이스
│  └─ ui/                        # HUD, 레벨업/일시정지/결과, 설정 패널, 터치 조작, 화면비 대응
├─ autoload/
│  ├─ game.gd                    # 전선/난이도, XP/레벨, 장비/인벤토리, 친구 선택, 기록 저장
│  ├─ settings.gd                # 화면/조작/접근성 설정 저장 및 즉시 적용
│  ├─ audio.gd                   # SFX 풀, BGM 루프/덕킹/피치
│  └─ fx.gd                      # 파티클, 충격파, 빔, 화면 효과
├─ addons/lit/                   # Lit - 2D Lighting Engine (MIT)
├─ assets/
│  ├─ art/                       # 캐릭터/친구 5종, 외계인, 환경, UI, 타이틀 원화
│  ├─ particles/                 # Kenney CC0 파티클 (라이선스 포함)
│  ├─ audio/                     # 직접 생성한 SFX + 64초 루프 BGM
│  └─ fonts/                     # Galmuri11 (OFL)
├─ screenshots/
├─ tools/                        # 에셋 생성 스크립트 (Python/Pillow/NumPy)
├─ README.md / CREDITS.md / THIRD_PARTY_NOTICES.md
└─ run_game.bat
```

---

## 무료 에셋 및 라이선스

| 사용처 | 에셋 | 라이선스 |
|---|---|---|
| VFX 파티클 | [Kenney Particle Pack](https://kenney.nl/assets/particle-pack) | **CC0 1.0** |
| 한국어 픽셀 폰트 | [Galmuri11](https://github.com/quiple/galmuri) by Lee Minseo | **SIL OFL 1.1** |
| 2D 조명 | [Lit - 2D Lighting Engine](https://github.com/shawndeprey/lit) by Fading Lantern Games | **MIT** |
| 캐릭터/외계인/군체/모선/UI/타이틀 아트 | 이 프로젝트를 위해 직접 생성 | 원작 |
| BGM/효과음 | 이 프로젝트를 위해 절차적으로 생성 | 원작 |
| 엔진 | Godot Engine 4.7.1 | MIT |

전체 라이선스 원문은 `assets/particles/LICENSE_kenney.txt`, `assets/fonts/OFL.md`,
`addons/lit/LICENSE`, `THIRD_PARTY_NOTICES.md`에 있습니다.

---

## 개발자 노트

- **에셋 재생성** (선택):
  ```bash
  cd tools
  python gen_characters.py
  python gen_aliens.py
  python gen_expansion.py
  python gen_world.py
  python gen_fx_ui.py
  python gen_evo_icons.py
  python gen_ability_icons.py
  python gen_new_weapon_icons.py
  python gen_equipment_icons.py
  python gen_friends.py
  python gen_menu_backdrop.py
  python gen_new_stages.py
  python gen_new_content.py
  python gen_relics.py
  python gen_stage_thumbs.py
  python gen_audio.py
  ```
  `Pillow`, `numpy`, `ffmpeg`가 필요합니다.
- **디버그 캡처** (개발용):
  ```bash
  godot --path . res://scenes/main.tscn -- --capture-game
  godot --path . res://scenes/main.tscn -- --stage=forest --capture-game --capture-diagonal
  godot --path . res://scenes/main.tscn -- --stage=forest --capture-relics
  godot --path . res://scenes/main.tscn -- --capture-hive
  godot --path . res://scenes/main.tscn -- --capture-ship
  godot --path . res://scenes/main.tscn -- --capture-queen
  godot --path . res://scenes/main.tscn -- --capture-boss
  godot --path . res://scenes/main.tscn -- --capture-evolution
  godot --path . res://scenes/main.tscn -- --capture-abilities
  godot --path . res://scenes/main.tscn -- --capture-lighting
  godot --path . res://scenes/main.tscn -- --capture-world-expansion
  godot --path . res://scenes/main.tscn -- --capture-crit
  godot --path . res://scenes/main.tscn -- --capture-new-skills
  godot --path . res://scenes/main.tscn -- --stage=dunes --capture-game
  godot --path . res://scenes/main.tscn -- --stage=dunes --capture-boss
  godot --path . res://scenes/main.tscn -- --stage=dawn --capture-game
  godot --path . res://scenes/stage_select.tscn -- --capture-select
  godot --path . res://scenes/stage_select.tscn -- --capture-select-late
  godot --path . res://scenes/stage_select.tscn -- --test-swipe
  godot --path . --resolution 720x1280 res://scenes/title.tscn -- --capture-title
  godot --path . --resolution 720x1280 res://scenes/stage_select.tscn -- --capture-select
  godot --path . --resolution 720x1280 res://scenes/main.tscn -- --stage=dunes --capture-game
  godot --path . --resolution 720x1280 res://scenes/equipment.tscn -- --capture-equipment
  godot --path . --resolution 720x1280 res://scenes/characters.tscn -- --capture-characters
  godot --path . res://scenes/main.tscn --rendering-method gl_compatibility -- --stage=dawn --bench-enemies=340
  godot --path . res://scenes/main.tscn -- --test-world-expansion
  godot --path . res://scenes/main.tscn -- --test-progression
  godot --path . res://scenes/main.tscn -- --test-final-fronts
  godot --path . res://scenes/main.tscn -- --stage=mirror --capture-game
  godot --path . res://scenes/main.tscn -- --stage=genesis --capture-boss
  godot --path . res://scenes/main.tscn -- --test-late-balance
  godot --path . res://scenes/main.tscn -- --test-evolutions
  godot --path . res://scenes/main.tscn -- --test-relics
  godot --path . res://scenes/main.tscn -- --test-new-skills
  godot --path . res://scenes/main.tscn -- --test-balance
  godot --path . res://scenes/main.tscn -- --stage=ship --capture-clear
  godot --path . res://scenes/main.tscn -- --capture-levelup
  godot --path . res://scenes/main.tscn -- --capture-banish
  godot --path . res://scenes/main.tscn -- --capture-combo
  godot --path . res://scenes/main.tscn -- --capture-pause-settings
  godot --path . res://scenes/main.tscn -- --capture-rewards
  godot --path . res://scenes/equipment.tscn -- --capture-equipment
  godot --path . res://scenes/equipment.tscn -- --capture-equipment-detail
  godot --path . res://scenes/equipment.tscn -- --test-drag
  godot --path . res://scenes/characters.tscn -- --capture-characters
  godot --path . res://scenes/main.tscn -- --friend=star --capture-game
  godot --path . res://scenes/main.tscn -- --touch --capture-game
  godot --path . res://scenes/main.tscn -- --touch --touch-right --touch-large --hud-large --capture-game
  godot --path . --resolution 720x1280 res://scenes/main.tscn -- --touch --touch-right --touch-large --hud-large --capture-game
  godot --path . res://scenes/main.tscn -- --touch --test-touch
  godot --path . -- --capture-settings
  godot --path . --resolution 720x1280 res://scenes/title.tscn -- --capture-settings
  godot --path . res://scenes/main.tscn -- --test-reroll-banish
  godot --path . res://scenes/main.tscn -- --test-enemy-projectile
  godot --path . res://scenes/main.tscn -- --test-background-pause
  godot --path . res://scenes/main.tscn -- --test-checkpoint-write
  godot --path . res://scenes/main.tscn -- --test-checkpoint-resume
  godot --path . res://scenes/title.tscn -- --test-title-continue
  godot --path . res://scenes/title.tscn -- --test-title-resume
  godot --path . res://scenes/main.tscn -- --test-settings-effects
  godot --path . res://scenes/main.tscn -- --test-platform-accessibility
  godot --path . res://scenes/stage_select.tscn -- --test-platform-input
  godot --path . res://scenes/main.tscn -- --test-equipment-run
  godot --path . res://scenes/equipment.tscn -- --test-equipment
  godot --path . res://scenes/characters.tscn -- --test-characters
  godot --path . res://scenes/main.tscn -- --test-modes
  godot --path . res://scenes/main.tscn -- --test-mobile-options
  godot --path . res://scenes/main.tscn -- --test-status
  godot --path . res://scenes/main.tscn -- --test-sets
  godot --path . res://scenes/main.tscn -- --test-weekly
  godot --path . res://scenes/equipment.tscn -- --test-gear-qol
  godot --path . res://scenes/equipment.tscn -- --capture-bulk
  godot --path . res://scenes/equipment.tscn -- --capture-loadout
  godot --path . res://scenes/stage_select.tscn -- --capture-weekly
  godot --path . --resolution 720x1280 res://scenes/stage_select.tscn -- --capture-weekly
  godot --path . res://scenes/altar.tscn -- --test-altar
  godot --path . res://scenes/main.tscn -- --test-companions
  godot --path . res://scenes/companions.tscn -- --test-companions-ui
  godot --path . res://scenes/companions.tscn -- --capture-companions
  godot --path . --resolution 720x1280 res://scenes/companions.tscn -- --capture-companions
  godot --path . res://scenes/altar.tscn -- --capture-altar
  godot --path . --resolution 720x1280 res://scenes/altar.tscn -- --capture-altar
  godot --path . res://scenes/main.tscn -- --endless --capture-endless
  godot --path . res://scenes/main.tscn -- --daily --capture-daily
  godot --path . res://scenes/main.tscn -- --endless --capture-endless-end
  godot --path . res://scenes/stage_select.tscn -- --capture-daily-modal
  godot --path . --resolution 720x1280 res://scenes/stage_select.tscn -- --capture-daily-modal
  godot --path . res://scenes/achievements.tscn -- --test-achievements
  godot --path . res://scenes/achievements.tscn -- --capture-achievements
  godot --path . --resolution 720x1280 res://scenes/achievements.tscn -- --capture-achievements
  godot --path . res://scenes/stage_select.tscn -- --capture-select
  ```
  결과는 `screenshots/`에 저장됩니다.
- **기록 저장 위치**: `%APPDATA%\Godot\app_userdata\DALBEAR- Earth Defense\dalbear_save.cfg`
  (기록 · 장비 인벤토리 · 장착 슬롯 · 달빛 조각 · 장비 레벨 · 선택한 친구 · 무한/일일 기록 · 업적이 함께 저장됩니다)
- **연출 설정 저장 위치**: `%APPDATA%\Godot\app_userdata\DALBEAR- Earth Defense\dalbear_settings.cfg`
- **Android 생명주기**: 홈/백그라운드 진입 시 자동 일시정지 + 체크포인트 저장, 복귀 시 일시정지 유지. 프로세스가 종료되어도 타이틀에서 이어하기가 가능합니다. 적 발사체는 이동 경로 기반 연속 충돌 판정을 사용합니다.
- **렌더러**: Windows는 **Forward+ + Lit 2D Lighting**, Android는 **GL Compatibility + 네이티브 CanvasModulate/PointLight2D 폴백**을 사용합니다.
- **Android 산출물**: `build/DALBEAR.apk` (디버그 서명 · minSdk 24 · targetSdk 36 · arm64-v8a)
- Android 빌드 환경: Godot 4.7.1 Android export templates, Android SDK(platform 34+), JDK 17+, 디버그 키스토어. Godot Editor Settings의 `export/android/android_sdk_path`와 `java_sdk_path`를 설정해야 합니다.
- **화면비**: `canvas_items` + `expand`. HUD/터치/오버레이는 viewport 크기 변경에 반응하고, 메뉴는 중앙 안전 영역 + 풀블리드 블러 배경을 사용합니다.
- 해상도: 1280×720 기준 `canvas_items` + `expand` 스트레치. HUD는 화면 가장자리, 메뉴는 중앙 안전 영역으로 배치됩니다. 픽셀아트는 2배 카메라 줌으로 표시됩니다.

---

## 만든 사람

**dalbear.com** · 2026
Godot 4.7.1 · Free/CC0/OFL assets only · 한국어 UI
