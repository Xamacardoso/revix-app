# Design

## Context

`Vehicle` atualmente não registra categoria, o SQLite está na versão 2 e a apresentação de garagem/detalhes usa ícones de carro fixos. O repositório ainda não tem uma especificação principal sincronizada; este change introduz a capacidade e registra os requisitos delta correspondentes.

## Goals / Non-Goals

**Goals:**
- Armazenar uma categoria tipada em cada veículo e manter compatibilidade com linhas antigas.
- Reutilizar a categoria para apresentar rótulos e ícones coerentes nas telas.
- Organizar documentação de produto, design, arquitetura e operação com navegação simples.

**Non-Goals:**
- Alterar cálculo, persistência ou unidade da quilometragem; todos os tipos continuam usando km nesta versão.
- Adicionar campos específicos de categoria, regras fiscais ou integração com catálogos externos.
- Copiar HTML, imagens, logotipos ou texto do Pixu; a referência é apenas a organização por artefato.

## Decisions

- Criar `VehicleType` no domínio com os valores `car`, `motorcycle`, `truck`, `van`, `bus` e `other`. Persistir seus nomes em maiúsculas em `vehicle_type` e fornecer fallback para `car` quando a chave não existe em mapas antigos.
- Manter categorias fechadas e explícitas por enquanto, com `other` como opção abrangente; considerar categorias personalizadas só quando existir necessidade de pesquisa ou comportamento específico por tipo.
- Avançar o esquema SQLite para v3 usando `ALTER TABLE vehicles ADD COLUMN ... NOT NULL DEFAULT 'CAR'` e um `CHECK` para os seis valores aceitos. A migração não reescreve veículos nem afeta manutenções.
- Centralizar rótulos e ícones de apresentação numa extensão/helper do feature, evitando dependência de Flutter dentro do domínio e evitando tabelas de mapeamento duplicadas em cada tela.
- Organizar `docs/` em decisões de produto/interface, design/wireframe, arquitetura/dados, operações, changelog e screenshots. O índice explicará que OpenSpec define requisitos normativos; documentação auxiliar resume decisões vigentes e orienta trabalho local.

## Risks / Trade-offs

- [Registros legados podem aparecer com categoria incorreta se a coluna for adicionada sem valor padrão] → usar `NOT NULL DEFAULT 'CAR'` e testar upgrade a partir de banco v2 com veículos existentes.
- [Uma lista fixa pode não cobrir um veículo especializado] → incluir “Outro veículo” e evitar atributos específicos nesta mudança.
- [A documentação pode divergir do comportamento] → incluir links para requisitos OpenSpec no índice e orientar que mudanças de comportamento atualizem OpenSpec e changelog.

## Migration Plan

1. Criar veículos novos com `vehicle_type` selecionado (carro como valor inicial).
2. Migrar automaticamente bancos v2 para v3 com valor `CAR` nos registros existentes.
3. Não há rollback automático para v2, pois versões antigas ignorariam o novo campo ao salvar; manter cópia local do banco antes de qualquer downgrade manual.

