# Wireframe: garagem e detalhes do veículo

Este wireframe textual descreve a hierarquia da experiência mobile; espaçamentos e aparência final ficam a cargo dos componentes Flutter existentes.

O fundo principal é branco `#FFFFFF`. Ações principais usam roxo `#725AC1`, textos usam carvão `#242038` e bordas usam neutro lavanda `#CAC4CE`. Creme `#F7ECE1` pode ser usado em superfícies secundárias. Consulte a [paleta completa](color-palette.md).

## Garagem

```text
┌ Revix ─────────────────────────────── Arquivados ┐
│ Sua garagem                 [+ Novo veículo]     │
│ [ Buscar por apelido, marca, modelo ou placa ]   │
│ ┌──────────────────────────────────────────────┐ │
│ │ [ícone] Carro                 [ABC1D23]      │ │
│ │                                              │ │
│ │ Meu Civic                                    │ │
│ │ Honda Civic G10 EXL                          │ │
│ │ [velocímetro] 52.300 km                 >    │ │
│ └──────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────┐ │
│ │ [ícone] Motocicleta                          │ │
│ │                                              │ │
│ │ Moto de viagem                               │ │
│ │ Honda CB 500                                 │ │
│ │ [velocímetro] 18.200 km                 >    │ │
│ └──────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

Cada veículo aparece uma vez em um card grande e retangular que ocupa a largura disponível; os cards ficam empilhados verticalmente. A busca filtra por apelido, marca, modelo ou placa; tocar em qualquer área do card abre os detalhes daquele veículo.

## Detalhes

```text
┌ Nome do veículo ───────────────────────── Opções ⋮ ┐
│ [ícone de categoria] Marca Modelo                  │
│ Tipo: Motocicleta                       Placa      │
│ Quilometragem atual: 18.200 km [Atualizar km]     │
│ Dados do veículo                                  │
│ Tipo · anos · combustível                         │
│ Histórico [Todas] [Preventivas] [Corretivas]     │
│ • Troca de óleo · data · 17.000 km                │
│ • Inspeção · data · km não informado              │
│                              [+ Registrar ação]   │
└──────────────────────────────────────────────────┘
```

## Cadastro e edição

O formulário apresenta um campo de tipo junto aos dados de identificação. O valor inicial é **Carro**; editar preserva a escolha existente. “Outro veículo” permite cadastrar veículos motorizados sem uma categoria dedicada, mantendo marca, modelo, combustível e km como dados comuns.

## Convenções de artefatos visuais

Wireframes são orientativos, não substituem cenários OpenSpec nem capturas do aplicativo. Guarde imagens produzidas pelo app em `../screenshots/` com a plataforma e o fluxo no nome do arquivo.
