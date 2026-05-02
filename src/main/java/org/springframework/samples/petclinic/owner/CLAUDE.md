# org.springframework.samples.petclinic.owner

## Purpose
All owner-centric domain: entities (`Owner`, `Pet`, `PetType`, `Visit`), their CRUD controllers, the sole Spring Data repository, and supporting formatter/validator.

## Key classes
- `Owner` — `@Entity`; pets loaded `FetchType.EAGER` via `@OneToMany(cascade=ALL)`; `addPet(pet)` silently no-ops if pet is not new; `addVisit(petId, visit)` throws `IllegalArgumentException` on unknown petId.
- `Pet` — extends `NamedEntity`; visits stored as `LinkedHashSet` ordered by date ASC; `birthDate` uses `@DateTimeFormat(pattern="yyyy-MM-dd")`.
- `Visit` — extends `BaseEntity` (not `NamedEntity`); constructor sets `date = LocalDate.now()` automatically.
- `PetType` — extends `NamedEntity`; body is empty; mapped to table `types`.
- `OwnerRepository` — extends `JpaRepository<Owner, Integer>`; `findPetTypes()` uses `@Query` JPQL; `findByLastNameStartingWith` returns `Page<Owner>`.
- `PetTypeFormatter` — `@Component` `Formatter<PetType>`; parses by name match against `findPetTypes()`; must be explicitly included in `@WebMvcTest` via `includeFilters`.
- `PetValidator` — plain `Validator` (no Bean Validation); registered via `@InitBinder("pet")` in `PetController`; type is only required on new pets.
- `OwnerController` — `@InitBinder` disallows `id` field; `@ModelAttribute("owner")` resolves owner for all `{ownerId}` routes; `showOwner` returns `ModelAndView`, others return `String`.
- `PetController` — class-level `@RequestMapping("/owners/{ownerId}")`; update writes through `updatePetDetails()` which mutates the existing pet in-memory then saves owner.
- `VisitController` — `@ModelAttribute("visit")` in `loadPetWithVisit` also populates `pet` and `owner` into the model map as a side effect.

## Conventions
- Controllers are package-private (`class`, not `public class`); only `PetTypeFormatter` and `PetValidator` are public.
- All controllers inject only `OwnerRepository` — there is no service layer; persistence goes directly through the repository.
- Successful POST handlers redirect using `"redirect:/owners/{ownerId}"` (Spring resolves the URI template variable from the path).
- Flash attributes carry `"message"` on success and `"error"` on validation failure.
- Page size is hardcoded to 5 in both `OwnerController` and `VetController`.
- `@InitBinder` blocks `id` from binding in every controller to prevent mass-assignment.

## Gotchas
- `PetController` `@WebMvcTest` must include `PetTypeFormatter` via `includeFilters`; omitting it causes `ConversionFailedException` when parsing pet type from form params.
- `Owner.getPets()` returns the live `ArrayList`; `addPet` only appends when `pet.isNew()` (id == null) — calling it on a persisted pet is silently ignored.
- `OwnerController.processUpdateOwnerForm` checks `owner.getId() != ownerId` using `!=` on `Integer` vs `int`; auto-unboxing makes this safe, but the `@ModelAttribute` pre-populates `owner` from the DB so `owner.getId()` reflects the DB id, not the form-submitted one (which is disallowed by `@InitBinder`).
- `Visit` date defaults to today in the constructor; the form can override it, but if the field is omitted the visit is still created with today's date.

## Testing
- Test files: `OwnerControllerTests`, `PetControllerTests`, `VisitControllerTests` — all `@WebMvcTest` with `@MockitoBean OwnerRepository`.
- `PetTypeFormatterTests` — `@ExtendWith(MockitoExtension.class)`, no Spring context.
- `PetValidatorTests` — `@ExtendWith(MockitoExtension.class)`, uses `MapBindingResult` directly.
- All controller tests annotated `@DisabledInNativeImage @DisabledInAotMode`.
- Repository integration tested in `src/test/java/.../service/ClinicServiceTests` (`@DataJpaTest`, H2 by default).
- Run package tests: `./mvnw test -pl . -Dtest="OwnerControllerTests,PetControllerTests,VisitControllerTests,PetTypeFormatterTests,PetValidatorTests"`
