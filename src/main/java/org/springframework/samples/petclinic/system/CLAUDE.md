# org.springframework.samples.petclinic.system

## Purpose
Application-wide infrastructure: cache setup, the welcome route, and an intentional-crash endpoint for error-handling demonstration.

## Key classes
- `CacheConfiguration` — `@Configuration(proxyBeanMethods=false)` + `@EnableCaching`; registers a single JCache cache named `"vets"` with statistics enabled; uses Caffeine as the JCache provider (declared in `pom.xml`).
- `WelcomeController` — maps `GET /` → Thymeleaf view `"welcome"`.
- `CrashController` — maps `GET /oups`; unconditionally throws `RuntimeException` to exercise Spring Boot's error rendering (both HTML `error.html` and JSON error response).

## Conventions
- All three classes are package-private.
- `CacheConfiguration` uses `proxyBeanMethods = false` (lite mode); do not add inter-bean method calls.
- The only named cache in the application is `"vets"` — defined here, consumed via `@Cacheable("vets")` in `VetRepository`.

## Gotchas
- `CacheConfiguration` uses `javax.cache` (JCache API) not `org.springframework.cache` directly; the `MutableConfiguration` only enables statistics — size/eviction policy is controlled by Caffeine's own config, not here.
- `CrashControllerIntegrationTests` excludes `DataSourceAutoConfiguration`, `DataSourceTransactionManagerAutoConfiguration`, and `HibernateJpaAutoConfiguration` via an inner `@SpringBootApplication` — it boots without a database to test error responses in isolation.

## Testing
- `CrashControllerTests` — plain unit test, no Spring context; instantiates `CrashController` directly and asserts `RuntimeException`.
- `CrashControllerIntegrationTests` — `@SpringBootTest(webEnvironment=RANDOM_PORT)`; uses `TestRestTemplate` to assert both JSON (`Map<String,Object>`) and HTML error responses from `/oups`; requires `server.error.include-message=ALWAYS` property to expose the message.
- Run: `./mvnw test -pl . -Dtest="CrashControllerTests,CrashControllerIntegrationTests"`
