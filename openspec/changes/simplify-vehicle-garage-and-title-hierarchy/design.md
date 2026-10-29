# Design

## Context

A tela da garagem atualmente combina cards horizontais selecionáveis, uma lista vertical separada e um resumo do veículo selecionado. O tema Material 3 define creme como superfície global. Consulte [proposal.md](proposal.md) para a motivação e as specs para os comportamentos esperados.

## Goals / Non-Goals

**Goals:**

- Reaproveitar os campos de pesquisa existentes e apresentar resultados como cards grandes, retangulares, de largura completa, em um único fluxo vertical.
- Tornar o card inteiro uma área de navegação para os detalhes.
- Definir branco como fundo global, mantendo os demais tokens da marca para ações, texto, bordas e acentos.
- Documentar uma regra de hierarquia aplicável às telas atuais e futuras.

**Non-Goals:**

- Alterar persistência, modelo de veículo, manutenção ou navegação de outras áreas.
- Adicionar filtros, ordenação ou ações novas à garagem.

## Decisions

- Manter a busca por apelido, marca, modelo e placa e aplicar o filtro diretamente à única coleção de cards. Isso evita duplicar cada veículo em componentes de listagem diferentes.
- Cada card retangular de aproximadamente 190 px de altura usa `Material`/`InkWell`, com o conteúdo visual do card grande original, e chama a navegação já existente para detalhes; não há estado de veículo selecionado nem resumo dependente da seleção na garagem.
- Usar o token semântico branco do tema no `Scaffold`, `AppBar`, superfícies de cards e campos. O creme permanece como cor de apoio para áreas pontuais, preservando a paleta aprovada.
- A garagem usa apenas o título “Sua garagem”; o botão “Novo veículo” permanece como ação na mesma linha. Seções distintas podem ter subtítulos próprios, conforme `interface-title-hierarchy`.
- Atualizar a documentação da paleta, os princípios de produto e o wireframe para refletir a interface implementada.

## Risks / Trade-offs

- Cards claros podem perder separação visual sobre o fundo branco → manter bordas lavanda e espaçamento entre os cards.
- Remover o resumo da garagem reduz informação imediatamente visível → os dados completos e o histórico continuam acessíveis no detalhe aberto diretamente pelo card.
