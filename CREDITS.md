# Credits

## DALBEAR: Earth Defense / 달베어: 지구를 지켜라

- **기획·세계관·도메인**: [dalbear.com](https://dalbear.com)
- **엔진**: [Godot Engine 4.7.1](https://godotengine.org) (MIT License)
- **제작 연도**: 2026

---

## 아트

### 이 프로젝트를 위해 직접 제작
- 플레이어 곰 '달베어' 스프라이트 및 애니메이션
- 달베어 친구 4종(별곰, 서리곰, 불꽃곰, 그림자곰) 팔레트 변형 스프라이트
- 외계인 43종 (기존 23종 + 신규 10개 전선의 새 몬스터 20종)
- 중간 보스 20종 (기존 10종 + 신규 10개 전선의 새 중간 보스 10종)
- 최종 보스 15종 (기존 5종 + 신규 10개 전선의 새 최종 보스 10종)
- 8방향 플레이어 시트(정면·정면 대각·측면·후면 대각·후면)
- 파괴 가능 지형 29종 (기존 9종 + 신규 전선 전용 유물 20종)
- 15개 전선 환경: 달빛 숲, 군체 분화구, 모선 심장부, 잿빛 균열, 달의 뒷면,
  붉은 사막, 얼어붙은 호수, 독성 수렁, 강철 폐허, 달빛 성채, 심연 해구,
  태양 흑점, 성운 미궁, 종말 궤도, 새벽의 문
- 월드 타일, 수목, 바위, 외계 크리스탈, 크레이터/작물 원, 잔해, 표지판, 군체/모선 프롭
- 투사체/젬/하트/충격파/레벨 업 링 등 VFX 텍스처, 산성탄
- HUD/강화 카드 아이콘 34종 (진화 무기 8종 + 대시/궁극기 + 장비 8종 포함)
- 전선 썸네일 15종
- 타이틀 키 아트 (달, 외계 함대, 숲, 곰, 랜턴)
- 게임 아이콘
- Android 런처 아이콘 192/432 변형 (기존 아이콘에서 파생)
- 와이드/폴드 화면용 블러 메뉴 배경 (타이틀 원화에서 파생)

생성 스크립트: `tools/gen_characters.py`, `tools/gen_aliens.py`, `tools/gen_expansion.py`,
`tools/gen_world.py`, `tools/gen_fx_ui.py`, `tools/gen_evo_icons.py`, `tools/gen_ability_icons.py`,
`tools/gen_equipment_icons.py`, `tools/gen_friends.py`, `tools/gen_new_stages.py`,
`tools/gen_new_content.py`, `tools/gen_relics.py`, `tools/gen_stage_thumbs.py`,
`tools/gen_menu_backdrop.py`, `tools/gen_icon.py`, `tools/gen_chapter_enemies.py`
(Python + Pillow로 절차 생성, 결과물은 `assets/art/`)

### Kenney Particle Pack (CC0 1.0)
- 제작: Kenney Vleugels ([kenney.nl](https://kenney.nl/assets/particle-pack))
- 사용 파일: star, spark, flare, magic, circle, smoke, muzzle, slash, dirt, symbol 등
- 위치: `assets/particles/`
- 라이선스: `assets/particles/LICENSE_kenney.txt` (CC0 1.0)
- 감사: Indigo Ray, Craig Nisbet, Zoltan Erdokovy, Heliagon, ThreeDee, Killst4r, Tim2501

---

## 폰트

### Galmuri11 (SIL Open Font License 1.1)
- 제작: Lee Minseo (quiple) · [github.com/quiple/galmuri](https://github.com/quiple/galmuri)
- 파일: `assets/fonts/Galmuri11.ttf`
- 라이선스 전문: `assets/fonts/OFL.md`
- 한국어 픽셀 UI에 사용했습니다.

---

## 2D 조명

### Lit - 2D Lighting Engine (MIT License)
- 제작: Shawn Deprey / Fading Lantern Games · [github.com/shawndeprey/lit](https://github.com/shawndeprey/lit)
- 위치: `addons/lit/`
- 라이선스 전문: `addons/lit/LICENSE`
- Windows Forward+ 빌드의 광원·그림자·라이트 버스트에 사용했습니다.
- Android GL Compatibility 빌드는 엔진 내장 `CanvasModulate`/`PointLight2D` 폴백을 사용합니다.

---

## 사운드

- **BGM**: 90 BPM, A minor, 64초 seamless loop. Python/NumPy로 합성, ffmpeg로 OGG 인코딩.
- **효과음**: 발사, 타격, 처치, 픽업, 회복, 피격, 레벨 업, 클릭, 레이저, 펄스, 보스, 승리, 패배, 대시, 궁극기.
- **가챠 연출음**: 차지 상승음, 임팩트, 전설 전용 임팩트. `tools/make_gacha_fx_assets.py`로 생성.
- 모두 이 프로젝트를 위해 절차적으로 생성한 원본 사운드입니다.
- 생성 스크립트: `tools/gen_audio.py`, `tools/make_gacha_fx_assets.py`

---

## 기타

- 게임 코드, 원본 아트, 원본 사운드: © 2026 dalbear.com.
- 외부 에셋은 위에 명시된 CC0/OFL 라이선스를 따릅니다.
- Godot 엔진과 그 기본 리소스는 Godot Engine의 MIT 라이선스를 따릅니다.

전체 제3자 라이선스 고지는 `THIRD_PARTY_NOTICES.md`를 참고하세요.
