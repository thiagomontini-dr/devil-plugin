# Guia do usuário - devil-plugin

Referência completa dos comandos, argumentos, intensidades, modo persistente e internals do plugin.

Created: 2026-07-08
Last update: 2026-10-07

## Instalação

Adicione o marketplace (repositório público no GitHub) e instale o plugin:

```
/plugin marketplace add thiagomontini-dr/devil-plugin
/plugin install devil@devil-marketplace
```

Ou pela linha de comando:

```
claude plugin marketplace add thiagomontini-dr/devil-plugin
claude plugin install devil@devil-marketplace
```

Os componentes passam a valer na próxima sessão do Claude Code.

## Comandos

| Comando | Argumentos | O que faz |
|---------|------------|-----------|
| `/devil:challenge` | `[light\|medium\|brutal] <ideia ou afirmação>` | Crítica em um turno: 3 falhas no raciocínio, 1 viés emocional ou cognitivo, 1 pergunta capaz de mudar sua opinião |
| `/devil:steelman` | `[light\|medium\|brutal] <posição>` | Constrói primeiro o contra-argumento mais forte possível, depois critica sua posição contra ele |
| `/devil:debate` | `[light\|medium\|brutal] <tema>` | Debate em múltiplas rodadas: uma objeção substantiva nova por rodada, sem conceder sem contestação sua, tabela final do que sobreviveu |
| `/devil:decision` | `[light\|medium\|brutal] <plano>` | Stress test pré-mortem: 5 razões para falhar, premissas ocultas, consequências não intencionais, critérios de abandono |
| `/devil:on` | `[light\|medium\|brutal]` | Ativa o modo devil persistente para o projeto atual |
| `/devil:off` | - | Desativa o modo devil persistente |
| `/devil:status` | - | Mostra se o modo devil persistente está ativo para o projeto atual |
| `/devil:help` | `[comando]` | Guia de uso, ou o protocolo detalhado de um comando |

Exemplo: `/devil:challenge brutal trabalho remoto é sempre melhor`.

## Dial de intensidade

Todo modo aceita uma intensidade opcional como primeiro argumento (padrão `medium`):

- `light` - perguntas investigativas, tom respeitoso, concede pontos genuinamente fortes
- `medium` - objeções diretas, sem elogios, concede apenas mediante evidência
- `brutal` - argumenta como se a posição estivesse completamente errada até prova em contrário

A intensidade muda apenas tom e pressão; as estruturas de saída fixas e as contagens de objeções nunca mudam (objeções demais diluem as mais fortes).

O advogado sempre responde no idioma em que o usuário escreve.

## Estruturas de saída

- Challenge: uma frase neutra reformulando a afirmação, `Flaws in the reasoning` (exatamente 3), `Emotional or cognitive bias` (exatamente 1, nomeado), `The question` (exatamente 1).
- Steelman: `Steelman` (o caso contrário mais forte possível), `Critique` (até 4 pontos, cada um contra o steelman), `Verdict` (o que sobrevive, o que reconsiderar).
- Debate: uma objeção forte por rodada com evidência; uma preocupação nova a cada rodada; nunca concede sem contestação substantiva (inclusive em `light`); limite flexível de 5 rodadas; tabela final objeção / contestação / sobreviveu.
- Decision não oferece mitigação, a menos que você peça.
- Decision: `Reasons this will fail` (exatamente 5, ranqueadas), `Hidden assumptions` (até 4, falsificáveis e com o teste mais barato), `Unintended consequences` (até 3), `Kill criteria` (2 a 3, mensuráveis e com prazo).

Toda crítica termina com o lembrete obrigatório: é brainstorming estruturado para revisão humana, não contraevidência verificada. No debate, cada rodada traz uma versão de uma linha e o resumo final, a versão completa.

## Modo devil persistente

O efeito de advogado do diabo decai em conversas longas conforme a instrução sai do contexto. `/devil:on` resolve isso: um hook UserPromptSubmit reinjeta uma instrução adversarial compacta a cada prompt, de modo que toda requisição recebe ao menos um questionamento substantivo enquanto a tarefa ainda é concluída.

- O estado fica em `~/.claude/devil-plugin/state/`, um arquivo por projeto (o nome do arquivo é o basename do projeto mais um hash do path completo, então projetos distintos nunca colidem; a linha 1 do arquivo é a intensidade, a linha 2 é o path do projeto). O path é canonicalizado antes do hash, então barra final, symlink ou `..` apontam para o mesmo estado.
- O diretório de estado é criado só por `/devil:on`, com permissão `700`, e os arquivos com `600`; `/devil:status` e o hook SessionStart apenas leem.
- Arquivo presente significa modo ligado; ausente, desligado; conteúdo inválido cai para `medium`.
- Um hook SessionStart avisa quando o modo devil está ativo para o projeto.
- Todas as falhas dos hooks degradam silenciosamente, para que nenhum prompt seja bloqueado.
- As operações `on`, `off` e `cleanup` são registradas em `~/.claude/devil-plugin/state/devil-mode.log` (a injeção a cada prompt não é registrada), rotacionado para uma única geração `.old` ao passar de 64 KB. Se o log for um symlink, nada é escrito.
- Projetos apagados ou movidos deixam arquivos de estado órfãos; `sh scripts/devil-mode.sh cleanup` remove todo estado cujo diretório registrado não existe mais.

## Agente e skill

- Agente `devil-advocate`: crítico adversarial somente leitura (Read, Grep, Glob) que outros workflows podem invocar para estressar um plano, design ou diff. Ele lê os arquivos referenciados e amarra cada objeção a linhas ou fatos específicos.
- Skill `devils-advocate`: ativa automaticamente em linguagem natural como "poke holes in this", "play devil's advocate", "o que pode dar errado", "aponte falhas", e direciona para a estrutura de crítica correspondente.

## Limites

- Toda crítica é brainstorming estruturado para revisão humana, não contraevidência verificada; afirmações factuais continuam exigindo verificação independente.
- A interação adversarial melhora de forma mensurável a qualidade das decisões, mas é percebida como mais trabalhosa e menos agradável; use o dial de intensidade de acordo.
- Melhores momentos para acionar: antes de decisões importantes, antes de lançamentos e sempre que houver concordância unânime.

## Change History
- Created: 2026-07-08
- Updated: 2026-10-07 - path canonicalizado, permissões do estado, log apenas em on/off/cleanup, regras de footer e concessão do debate
