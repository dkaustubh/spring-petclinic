# org.springframework.samples.petclinic.vet

## Purpose
Read-only vet directory: domain entities, a cached repository, and a controller that serves both a paginated HTML view and a JSON/XML REST endpoint.

## Key classes
- `Vet` — extends `Person`; specialties in a `Set<Specialty>` loaded `FetchType.EAGER` via `@ManyToMany` join table `vet_specialties`; `getSpecialties()` returns a sorted `List` (by name); `getSpecialtiesInternal()` is protected and lazy-initializes the set.
- `Specialty` — extends `NamedEntity`; body is empty; mapped to table `specialties`.
- `Vets` — JAXB wrapper (`@XmlRootElement`) around `List<Vet>`; exists solely to enable XML/JSON marshalling of the collection; `getVetList()` lazy-initializes the list.
- `VetRepository` — extends `Repository<Vet, Integer>` (minimal interface, not `JpaRepository`); both `findAll()` overloads annotated `@Cacheable("vets")` and `@Transactional(readOnly=true)`; cache name `"vets"` must match `CacheConfiguration`.
- `VetController` — package-private `@Controller`; `GET /vets.html` returns Thymeleaf view with pagination; `GET /vets` returns `@ResponseBody Vets` (JSON by default, XML if `jakarta.xml.bind` is on classpath — it is).

## Conventions
- `VetRepository` uses the minimal `Repository` marker interface, not `JpaRepository` — `save`, `delete`, etc. are intentionally unavailable; vets are read-only from the application's perspective.
- Both `findAll()` variants are cached under the same key `"vets"`; adding a paginated variant that bypasses cache would silently serve stale data.
- `Vet` is registered in `PetClinicRuntimeHints` for Java serialization (required for cache serialization in some configurations).

## Gotchas
- `GET /vets` and `GET /vets.html` are two distinct endpoints on the same controller — the `.html` suffix is not content negotiation, it is a literal path difference.
- `Vet.getSpecialties()` always returns a new sorted `List` derived from the internal `Set`; do not rely on reference equality between calls.
- `VetRepository` extends `Repository`, so Spring Data does not expose `findById` — looking up a single vet by id requires a custom query method or switching to `CrudRepository`.
- `@Cacheable` on `findAll(Pageable)` caches by pageable key; different page requests each get their own cache entry under the `"vets"` cache, but the cache has no size limit configured in `CacheConfiguration`.

## Testing
- `VetControllerTests` — `@WebMvcTest(VetController.class)` with `@MockitoBean VetRepository`; tests both HTML view (`/vets.html`) and JSON response (`/vets`); annotated `@DisabledInNativeImage @DisabledInAotMode`.
- `VetTests` — plain unit test; verifies `Vet` round-trips through Java serialization using `SerializationUtils`.
- Vet repository integration tested in `src/test/java/.../service/ClinicServiceTests` (`@DataJpaTest`).
- Run: `./mvnw test -pl . -Dtest="VetControllerTests,VetTests"`
