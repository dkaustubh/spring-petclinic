# org.springframework.samples.petclinic.model

## Purpose
Provides abstract `@MappedSuperclass` base entities shared across all domain packages; contains no concrete `@Entity` classes.

## Key classes
- `BaseEntity` — `@MappedSuperclass` with `Integer id` (IDENTITY strategy) and `isNew()` (id == null); implements `Serializable` for AOT/serialization hints.
- `NamedEntity` — extends `BaseEntity`; adds `@NotBlank name`; `toString()` returns `getName()`, which drives Thymeleaf `<select>` rendering.
- `Person` — extends `BaseEntity` (not `NamedEntity`); adds `@NotBlank firstName` + `lastName`; base for `Owner` and `Vet`.

## Conventions
- Inheritance chain for named lookup entities: `BaseEntity` → `NamedEntity` (e.g., `PetType`, `Specialty`).
- Inheritance chain for people: `BaseEntity` → `Person` (e.g., `Owner`, `Vet`).
- All superclasses use `@MappedSuperclass`, never `@Entity`; concrete subclasses own the `@Table` annotation.
- Validation constraints (`@NotBlank`) live on the superclass fields; subclasses add their own constraints without repeating inherited ones.
- `id` is `Integer` (nullable), not `int`; `isNew()` is the canonical null-check used throughout controllers and validators.

## Gotchas
- `Person` extends `BaseEntity` directly, not `NamedEntity` — there is no shared `name` field on people; `firstName`/`lastName` are separate columns.
- `BaseEntity` is registered explicitly in `PetClinicRuntimeHints` for serialization; adding a new serializable superclass requires a matching hint registration there.

## Testing
- Test file: `src/test/java/.../model/ValidatorTests.java`
- Plain unit test — no Spring context, no `@DataJpaTest`; instantiates `LocalValidatorFactoryBean` directly.
- Run in isolation: `./mvnw test -pl . -Dtest=ValidatorTests`
