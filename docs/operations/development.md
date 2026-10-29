# Desenvolvimento local

## Requisitos

- Flutter SDK compatível com `pubspec.yaml`.
- Android SDK para Android; macOS com Xcode para executar iOS.
- Windows com ferramentas de build do Visual Studio para alvo Windows.

## Preparar e executar

```sh
flutter pub get
flutter devices
flutter run -d <device-id>
```

## Verificar alterações

```sh
dart format lib test
flutter analyze
flutter test
openspec validate <change-name>
```

Para mudanças SQLite, incluir um teste com banco legado populado, conferir os dados após migração e fechar/reabrir o banco. Para mudanças de interface, cobrir criação, edição e apresentação dos dados nos testes de widget.

## Organização do trabalho

1. Para comportamento novo ou alterado, criar um change OpenSpec com proposta, delta de especificação, design e tarefas.
2. Implementar tarefas e testes; não sincronizar ou arquivar o change até que as verificações requeridas estejam concluídas.
3. Atualizar este material quando decisões, estrutura de dados ou comandos locais mudarem.
