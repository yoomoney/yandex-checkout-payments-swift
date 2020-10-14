import MoneyAuth
import YandexCheckoutWalletApi

enum AuthorizationProcessingAssembly {
    static func makeService(
        isLoggingEnabled: Bool,
        testModeSettings: TestModeSettings?,
        moneyAuthCenterClientId: String
    ) -> AuthorizationProcessing {
        let yamoneyLoginService = YamoneyLoginAssembly
            .makeYamoneyLoginService(isLoggingEnabled: isLoggingEnabled,
                                     testModeSettings: testModeSettings)
        let deviceInfoService = DeviceInfoProviderAssembly.makeDeviceInfoProvider()
        let settingsStorage = KeyValueStoringAssembly.makeSettingsStorage()

        let tokenStorage: KeyValueStoring
        switch testModeSettings {
        case .some(let testModeSettings):
            tokenStorage = KeyValueStoringAssembly.makeMockKeychainStorage(
                testModeSettings: testModeSettings
            )
        case .none:
            tokenStorage = KeyValueStoringAssembly.makeKeychainStorage()
        }

        let moneyAuthConfig = MoneyAuthAssembly.makeMoneyAuthConfig(
            moneyAuthCenterClientId: moneyAuthCenterClientId,
            yxOauthClientId: nil,
            loggingEnabled: isLoggingEnabled
        )
        let moneyAuthRevokeTokenService = RevokeTokenServiceFactory.makeService(
            config: moneyAuthConfig
        )
        let authorizationMediator = AuthorizationMediator(
            tokenStorage: tokenStorage,
            yamoneyLoginService: yamoneyLoginService,
            deviceInfoService: deviceInfoService,
            settingsStorage: settingsStorage,
            moneyAuthRevokeTokenService: moneyAuthRevokeTokenService
        )
        return authorizationMediator
    }
}
