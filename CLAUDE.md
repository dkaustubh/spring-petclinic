# Spring PetClinic — AI Agent Orientation

## Purpose
Spring PetClinic is a reference Spring Boot web application that demonstrates idiomatic use of the framework for a simple veterinary-clinic management domain.

## Tech stack
- Spring Boot 3.4.2 (parent POM)
- Java 17 (minimum; newer versions work)
- Build tool: Maven (wrapper `./mvnw`); Gradle wrapper also present but CSS profile is Maven-only
- Persistence default: H2 in-memory; MySQL and PostgreSQL supported via profiles `mysql` / `postgres`
- View layer: Thymeleaf
- Test framework: JUnit 5 (Jupiter) + AssertJ, via `spring-boot-starter-test`

## Build / test / run commands
```
./mvnw package                                          # compile, test, package JAR
./mvnw spring-boot:run                                  # run app on localhost:8080
./mvnw test                                             # full test suite (H2)
./mvnw test -Dtest=ClinicServiceTests                   # single test class
./mvnw test -Dtest=ClinicServiceTests#shouldFindVets    # single test method
./mvnw validate                                         # lint/format check (spring-javaformat + nohttp)
./mvnw spring-javaformat:apply                          # apply spring-javaformat auto-formatting
```

## Package map
All packages live under `src/main/java/org/springframework/samples/petclinic/`.

| Package | CLAUDE.md | What you'll find |
|---------|-----------|-----------------|
| `model` | [`model/CLAUDE.md`](src/main/java/org/springframework/samples/petclinic/model/CLAUDE.md) | Abstract `@MappedSuperclass` base entities (`BaseEntity`, `NamedEntity`, `Person`); no concrete `@Entity` classes |
| `owner` | [`owner/CLAUDE.md`](src/main/java/org/springframework/samples/petclinic/owner/CLAUDE.md) | All owner-centric domain: `Owner`, `Pet`, `Visit`, `PetType`, their CRUD controllers, `OwnerRepository`, formatter, and validator |
| `vet` | [`vet/CLAUDE.md`](src/main/java/org/springframework/samples/petclinic/vet/CLAUDE.md) | Read-only vet directory: `Vet`, `Specialty`, `Vets` wrapper, cached `VetRepository`, paginated HTML + JSON controller |
| `system` | [`system/CLAUDE.md`](src/main/java/org/springframework/samples/petclinic/system/CLAUDE.md) | Application-wide infrastructure: `CacheConfiguration`, `WelcomeController`, `CrashController` |

## Cross-cutting conventions
- **No service layer.** Controllers inject repositories directly; there are no `@Service` classes.
- **Controllers are package-private.** Every `@Controller` class omits `public`; only formatters and validators are `public`.
- **`@InitBinder` blocks `id` binding** in every controller via `dataBinder.setDisallowedFields("id")` to prevent mass-assignment.
- **Flash attribute naming:** `"message"` on success, `"error"` on validation failure — used consistently across `OwnerController` and `PetController`.
- **Page size of 5** is hardcoded in both `OwnerController.findPaginatedForOwnersLastName` and `VetController.findPaginated`.
- **Entity inheritance:** `BaseEntity` → `NamedEntity` (named lookup entities such as `PetType`, `Specialty`); `BaseEntity` → `Person` (people: `Owner`, `Vet`). All superclasses are `@MappedSuperclass`; concrete subclasses own `@Table`.
- **Bean validation constraints** (`@NotBlank`, etc.) live on superclass fields; subclasses do not repeat inherited constraints.

## Gotchas that span packages
- **`"vets"` cache name** is defined in `CacheConfiguration` (`system/`) and consumed by `@Cacheable("vets")` in `VetRepository` (`vet/`). The string must match exactly in both places.
- **`PetClinicRuntimeHints`** registers `BaseEntity`, `Person`, and `Vet` for Java serialization (required for AOT/native). Any new serializable type that participates in caching or AOT must be registered there.
- **nohttp-checkstyle** runs on every `./mvnw validate` and forbids `http://` URLs anywhere in source files (Java, XML, properties, HTML). Always use `https://`.

## Testing strategy
- **Unit tests** (no Spring context): `ValidatorTests`, `CrashControllerTests`, `PetTypeFormatterTests`, `PetValidatorTests`, `VetTests`.
- **`@WebMvcTest` slice tests** (controller layer only, mocked repository): `OwnerControllerTests`, `PetControllerTests`, `VisitControllerTests`, `VetControllerTests`. All annotated `@DisabledInNativeImage @DisabledInAotMode`.
- **`@DataJpaTest` integration test** (real JPA, H2 by default): `ClinicServiceTests` in `src/test/java/.../service/`. Uses `@AutoConfigureTestDatabase(replace=NONE)` so the active profile's datasource is respected.
- **Full-stack integration tests**: `PetClinicIntegrationTests` (H2), `MySqlIntegrationTests` (Testcontainers, requires Docker), `PostgresIntegrationTests` (Docker Compose).
- Default test profile: H2 in-memory. No `src/test/resources/application-mysql.properties` exists; MySQL tests activate the `mysql` Spring profile via `@ActiveProfiles("mysql")` and spin up a container via Testcontainers.
- Run a package-scoped subset: `./mvnw test -Dtest="OwnerControllerTests,PetControllerTests,VisitControllerTests"`.

## How AI agents should use these files
Read this file first. If your change touches a specific package, read the corresponding `CLAUDE.md` listed in the package map above before editing any code. The package files contain class-level details, edge-case conventions, and gotchas that are not visible from code structure alone. Do not duplicate their content here; follow the pointer.
