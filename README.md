# devil-plugin

O plugin que faz o Claude Code discordar de você — quando é isso que você precisa.

## O problema

Assistentes de IA concordam demais. Existe até nome para isso: *sycophancy* — o viés documentado de LLMs preferirem respostas que validam o usuário a respostas verdadeiras porém desagradáveis. Na prática, significa que sua pior ideia e sua melhor ideia recebem o mesmo "ótima ideia!". Quando você usa a IA para decidir algo importante, esse é um defeito perigoso: você não está pensando melhor, está apenas ouvindo um eco.

## O que é um advogado do diabo

Advogado do diabo é um papel deliberado de oposição: alguém encarregado de argumentar contra uma posição — não por acreditar no contrário, mas para expor falhas, premissas ocultas e riscos que o entusiasmo esconde. A técnica vem dos processos de canonização da Igreja e sobrevive até hoje em comitês de decisão, red teams e revisões de projeto, porque funciona: oposição estruturada melhora a qualidade das decisões de forma mensurável.

Este plugin transforma o Claude Code nesse opositor sob demanda. Pesquisas mostram que a atribuição explícita do papel — combinada com proibição de concordar, estrutura de saída fixa, exigência de objeções concretas e falsificáveis e reancoragem da instrução em conversas longas — eleva drasticamente a discordância genuína do modelo. O plugin empacota exatamente essas condições.

## O que você ganha

- Falhas encontradas antes do lançamento, não depois.
- Premissas ocultas explicitadas como afirmações testáveis, com o teste mais barato para cada uma.
- Critérios objetivos de abandono definidos antes de o custo afundado falar mais alto.
- Um freio contra o pensamento de grupo — inclusive o grupo formado por você e sua IA.

## Casos de uso

- Antes de uma decisão importante: `/devil:decision` roda um pré-mortem — 5 razões para o plano falhar, premissas ocultas, consequências não intencionais e critérios de abandono.
- Ao avaliar uma ideia ou argumento: `/devil:challenge` devolve 3 falhas no raciocínio, 1 viés cognitivo e a pergunta que poderia mudar sua opinião.
- Quando você quer ouvir o outro lado de verdade: `/devil:steelman` constrói a versão mais forte possível da posição contrária antes de criticar a sua.
- Quando você quer pressão contínua: `/devil:debate` sustenta um debate em rodadas, e `/devil:on` ativa um modo persistente em que todo prompt do projeto recebe ao menos um questionamento substantivo — sem deixar de completar a tarefa.
- Dentro de outros workflows: o agente `devil-advocate` estressa planos, designs e diffs lendo os arquivos e amarrando cada objeção a linhas específicas.

Todo modo tem um dial de intensidade (`light`, `medium`, `brutal`) e responde no idioma em que você escreve. Toda crítica termina lembrando que é brainstorming estruturado para revisão humana, não contraevidência verificada.

## Instalação

```
/plugin marketplace add thiagomontini-dr/devil-plugin
/plugin install devil@devil-marketplace
```

Os componentes passam a valer na próxima sessão do Claude Code.

## Documentação

O guia completo — todos os comandos, argumentos, o dial de intensidade, o modo persistente e seus internals — está em [docs/USER_GUIDE.md](docs/USER_GUIDE.md). Dentro do Claude Code, `/devil:help` mostra o mesmo guia sem sair da sessão.
