# Contributing to TamuKu

> Panduan kontribusi untuk proyek Buku Tamu Digital — Universitas Cakrawala

---

## Tim

| Nama | Fokus |
|------|-------|
| Hafiz Nur Rizki | Firebase & Backend |
| Ahmad Fauzan | Architecture & Full Stack |
| Annur Syahrin Aisyah | UI/UX & Frontend |

---

## Development Workflow

### Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code |
| `develop` | Integration branch |
| `feature/[name]` | New features (e.g., `feature/qr-scanner`) |
| `fix/[name]` | Bug fixes (e.g., `fix/checkout-timer`) |
| `chore/[name]` | Maintenance tasks (e.g., `chore/update-deps`) |

### Commit Message Format

```
[type] Short description

Detailed explanation (if needed)

Refs: #issue-number
```

**Types:**

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring |
| `test` | Adding tests |
| `chore` | Build/config changes |

**Examples:**

```
[feat] Add QR scanner screen with camera overlay

[fix] Correct check-out time calculation for overnight visits

[docs] Update DESIGN.md with dark mode tokens

[test] Add unit tests for guest_form_provider
```

### Pull Request Process

1. Create feature branch from `develop`
3. Implement changes following the project's coding standards
3. Run `flutter analyze` — must pass with **0 issues**
4. Write tests for new service/model code
5. Update [DESIGN.md](DESIGN.md) if adding new components
6. Create PR with description of changes
7. At least **1 team member review** before merge

---

## Coding Standards

### Before Writing Code

1. Read [DESIGN.md](DESIGN.md) section for the component/screen you're building
2. Check existing widgets in `lib/widgets/` for reusable components
3. Check existing providers in `lib/providers/` for state patterns
4. Check `lib/services/` for existing Firebase operations

### While Coding

| Rule | Detail |
|------|--------|
| State management | Riverpod for ALL state — **no `setState`** |
| UI language | Bahasa Indonesia |
| Constructors | Use `const` everywhere |
| File length | Maximum **300 lines** per file |
| Strings | No hardcoded strings — use `constants.dart` |
| Comments | Doc comments on all public APIs |
| Naming | Follow Effective Dart conventions |

### Before Committing

1. Run `flutter analyze` — **0 issues** required
2. Run existing tests — all must pass
3. Write tests for new service/model code
4. Check formatting: `dart format .`

---

## Design System Compliance

All UI must follow [DESIGN.md](DESIGN.md) tokens:

- **Colors**: Use color tokens (`primary-500`, `neutral-100`, etc.)
- **Spacing**: Use spacing system (`space-xs`, `space-sm`, `space-md`, etc.)
- **Typography**: Use typography scale (`heading-lg`, `body-md`, etc.)
- **Border radii**: Use radius tokens (`radius-sm`, `radius-md`, etc.)
- **Accessibility**: Check contrast ratios — **WCAG AA minimum**

---

## Testing

### Required Tests

| Test Type | Scope |
|-----------|-------|
| **Unit tests** | All services and models |
| **Widget tests** | All screens |
| **Integration tests** | Critical flows (scan → form → submit → confirm) |

### Running Tests

```bash
flutter test                    # Run all tests
flutter test --coverage        # Run with coverage report
flutter test test/unit/        # Run only unit tests
flutter test test/widget/      # Run only widget tests
```

### Coverage Target

| Layer | Target |
|-------|--------|
| Services | 80%+ |
| Models | 100% (simple data classes) |

---

## Documentation

| When | Update |
|------|--------|
| New workflow rules | This file (`CONTRIBUTING.md`) |
| New architectural patterns | `DESIGN.md` |
| New components or token changes | [DESIGN.md](DESIGN.md) |
| New features or setup steps | [README.md](README.md) |

---

## Questions?

| Topic | Contact |
|-------|---------|
| Architecture decisions | Ahmad Fauzan |
| Firebase & Backend | Hafiz Nur Rizki |
| UI/UX | Annur Syahrin Aisyah |

---

*Proyek UAS Mobile Computing — Universitas Cakrawala*
