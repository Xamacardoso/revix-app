# Changelog

Mudanças relevantes do Revix. As especificações OpenSpec mantêm o histórico detalhado de requisitos e aceitação.

## Não lançado

- Logotipo do Revix integrado ao cabeçalho e ao estado vazio da garagem.
- Cadastro de carros, motocicletas, caminhões, vans, ônibus e outros veículos motorizados.
- Migração SQLite v3 preserva veículos existentes e os trata como carros.
- Documentação de produto, design, arquitetura e operação organizada em `docs/`.

## Base offline-first

- Persistência local SQLite para veículos e histórico de manutenção.
- Arquivamento/restauração de veículos sem apagar o histórico.
- Quilometragem da manutenção opcional, com migração SQLite v2.
- Garagem com cards de acesso rápido e lista vertical com busca.
