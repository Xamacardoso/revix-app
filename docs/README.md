# Documentação do Revix

Esta pasta reúne material auxiliar para entender, desenhar, operar e manter o Revix. Os documentos são escritos para o produto atual, com persistência SQLite local e interface Flutter.

A organização por decisões de produto, materiais de design, operação e capturas foi inspirada no [repositório Pixu](https://github.com/ryofac/pixu), com nomes e conteúdo próprios do Revix.

## Navegação

| Área | Conteúdo |
| --- | --- |
| [Produto](product/requirements.md) | Escopo, princípios, usuários e requisitos resumidos |
| [Decisões de produto e interface](product-design.md) | Direção visual e escolhas de experiência |
| [Paleta de cores](design/color-palette.md) | Tokens de marca, papéis e orientações de contraste |
| [Logotipo](design/logo-usage.md) | Artefato de marca aprovado e locais de uso no app |
| [Design](design/vehicle-management-wireframe.md) | Fluxos e wireframe textual do gerenciamento de veículos |
| [Arquitetura e dados](architecture/data-model.md) | Camadas, entidades, persistência e evolução do banco |
| [Desenvolvimento local](operations/development.md) | Preparação do ambiente, comandos e verificações |
| [Checklist de entrega](operations/release-checklist.md) | Conferências antes de distribuir builds |
| [Changelog](CHANGELOG.md) | Mudanças entregues e alterações relevantes |
| [Capturas de tela](screenshots/README.md) | Convenções para imagens reais do aplicativo |

## Fonte normativa

Os requisitos comportamentais vigentes são mantidos em [`../openspec/`](../openspec/). Este material oferece orientação e resumos; quando um resumo divergir de uma especificação OpenSpec aprovada, a especificação prevalece. Mudanças de comportamento devem ser propostas no OpenSpec e refletidas aqui quando alterarem decisões, dados ou instruções de uso.
