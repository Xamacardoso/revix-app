# Revix

Aplicativo Flutter para acompanhar veículos e seus registros de manutenção. O primeiro estágio usa persistência local SQLite e funciona sem conexão; autenticação, sincronização e backup em nuvem ficam para uma etapa futura.

## Requisitos

- Flutter SDK estável compatível com as dependências do `pubspec.yaml`.
- Para Android: Android SDK configurado e um dispositivo ou emulador.
- Para iOS: macOS com Xcode e um simulador ou dispositivo iOS.
- Para executar a validação desktop neste workspace: Windows com ferramentas de build do Visual Studio.

## Executar

Instale as dependências:

```sh
flutter pub get
```

Liste os alvos disponíveis:

```sh
flutter devices
```

No Windows, execute:

```sh
flutter run -d windows
```

Em Android ou iOS, substitua o alvo pelo identificador exibido por `flutter devices`:

```sh
flutter run -d <device-id>
```

## Persistência local

O SQLite mantém tabelas separadas para veículos e manutenções, relacionadas por `vehicle_id` e protegidas por chave estrangeira. Os repositórios de cada capacidade ficam separados; as telas usam esses repositórios e não acessam o banco diretamente.

Cada registro recebe UUID, timestamps e `user_id = mock_user_default`. O esquema atual está na versão 3; evoluções devem ser aplicadas por migrações incrementais. Veículos são arquivados sem apagar as manutenções associadas. Valores monetários são armazenados em centavos inteiros.

No Windows, o banco `revix.db` fica na pasta de suporte da aplicação, dentro de `revix/`. Em Android e iOS, fica na pasta de banco padrão fornecida por `sqflite`. Os dados permanecem no aparelho e são mantidos entre reinicializações. Não há cópia em nuvem nesta versão.

## Verificações locais

```sh
flutter analyze
flutter test
```

### Resultado da validação deste ambiente

- `flutter test`: 38 testes passaram. A suíte cobre migrações v1-v3, persistência SQLite, tipos de veículo, odoômetro opcional, garagem pesquisável, tooltips, fonte local e atualização imediata de quilometragem.
- `flutter analyze`: sem problemas.
- Windows: o app iniciou em modo debug e disponibilizou o serviço Dart VM.
- Android: o build release foi concluído; o APK está em `build/app/outputs/flutter-apk/app-release.apk`. A instalação no aparelho conectado foi cancelada pelo dispositivo (`INSTALL_FAILED_USER_RESTRICTED`), então o fluxo ainda precisa ser aberto no aparelho após permitir a instalação USB.
- iOS: execução pendente; este ambiente Windows não tem macOS/Xcode.

## Interface e migração do histórico

A versão 2 do banco permite registros de manutenção sem quilometragem do serviço. A migração preserva os registros existentes e recria os índices da tabela. Ao deixar o campo vazio, o aplicativo salva `null`, não solicita atualização do odômetro do veículo e mostra “km não informado” na linha do tempo.

A versão 3 adiciona a categoria do veículo e mantém os registros anteriores como carros. São aceitos carros, motocicletas, caminhões, vans, ônibus e outros veículos motorizados.

A garagem exibe cards de acesso rápido e uma lista vertical com busca por apelido, marca, modelo ou placa. Os formulários de veículos e manutenções apresentam ícones e dicas contextuais. A fonte Inter é incluída como asset para funcionar sem conexão.

## Documentação

Consulte [docs/README.md](docs/README.md) para requisitos do produto, decisões de interface, wireframes, arquitetura, desenvolvimento, checklist de entrega, changelog e convenção de capturas de tela. Requisitos normativos continuam em `openspec/`.
