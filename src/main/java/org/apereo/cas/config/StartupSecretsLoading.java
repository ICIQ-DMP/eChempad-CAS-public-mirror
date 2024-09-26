package org.apereo.cas.config;

import org.springframework.boot.context.event.ApplicationEnvironmentPreparedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Logger;

/**
 * This class is loaded via src/resources/META-INF/spring.factories, not via bean injection as usual.
 * <p>
 * The reason of this is that this code must be executed before any context initialization takes place, which includes
 * the load of beans. Since this class is technically a bean, it will not be loaded if not loaded via al alternative
 * method.
 * <p>
 * Basically, we have a deadlock: to initialize beans we need database password, but to read database password we need
 * to initialize beans so by defining this bean outside the standard initialization cycle, we can break out of it.
 * <p>
 * This class loads secrets into the Java environment before initializing any beans. This is needed because some secrets
 * are needed to load those beans. If we wait for the beans to be loaded, the application crash because some of the data
 * needed to define those beans is missing.
 * <p>
 * In this case in particular, we need to load the DB password before defining the Datasource bean, or our app crashes.
 * Other cases may be added since the definition of this class.
 * <p>
 * @author Institut Català d'Investigació Química (iciq.cat)
 * @author Aleix Mariné-Tena (amarine@iciq.es, github.com/AleixMT)
 * @author Carles Bo Jané (cbo@iciq.es)
 * @author Moisés Álvarez (malvarez@iciq.es)
 * @version 1.0
 * @since 26/09/2024
 */
public class StartupSecretsLoading implements ApplicationListener<ApplicationEnvironmentPreparedEvent> {

    private final static String SECRETS_FOLDER = "/run/secrets/";

    /**
     * Reads a secret and introduces it into the environment of .application properties.
     *
     * @param secretName name of the secret to read from /run/secrets default Docker secrets folder.
     * @param property Property to write / update.
     * @param configurableEnvironment Provides the access to the environment for manipulation.
     */
    private void addSecretProperty(String secretName, String property, ConfigurableEnvironment configurableEnvironment)
    {
        String secretPath = SECRETS_FOLDER + secretName;

        try {
            String secretContent = Files.readString(Paths.get(secretPath));
            System.setProperty(property, secretContent);
        } catch (IOException e) {
            System.err.println("Failed to read the secret: " + e.getMessage());
        }
    }

    /**
     * Loads all secrets into the Java properties environment
     * @param environment Object connected to the environment of the app, so we can get write access of these variables
     *                    from it.
     */
    private void loadSecrets(ConfigurableEnvironment environment) {
        Map<String, Object> propertyOverrides = new LinkedHashMap<>();
        try {
            this.addSecretProperty("CAS_TGC_CRYPTO_ENCRYPTION_KEY", "cas.tgc.crypto.encryption.key", environment);
            this.addSecretProperty("CAS_TGC_CRYPTO_SIGNING_KEY", "cas.tgc.crypto.signing.key", environment);
            this.addSecretProperty("CAS_WEBFLOW_CRYPTO_SIGNING_KEY", "cas.webflow.crypto.signing.key", environment);
            this.addSecretProperty("CAS_WEBFLOW_CRYPTO_ENCRYPTION_KEY", "cas.webflow.crypto.encryption.key", environment);
            this.addSecretProperty("LDAP_TOKEN", "cas.authn.ldap[0].bind-credential", environment);
            this.addSecretProperty("DB_PASSWORD", "cas.authn.jdbc.query[0].password", environment);
            this.addSecretProperty("ORCID_TOKEN", "cas.authn.pac4j.oauth2[0].secret", environment);
        } catch (Exception e) {
            throw new RuntimeException("Failed to load secrets from /run/secrets", e);
        }

        // Add the loaded properties to the environment
        environment.getPropertySources().addFirst(new MapPropertySource("customSecrets", propertyOverrides));
    }

    /**
     * This method is executed before loading beans and after the basic environment initializations. You can inject data
     * needed for the initialization of those beans.
     * <p>
     * @param event Event object that contains information about the ApplicationEnvironmentPreparedEvent event.
     */
    @Override
    public void onApplicationEvent(ApplicationEnvironmentPreparedEvent event) {
        Logger.getGlobal().warning("Loading secrets from " + SECRETS_FOLDER);
        this.loadSecrets(event.getEnvironment());
        Logger.getGlobal().warning("Finished loading secrets from " + SECRETS_FOLDER);
    }

}