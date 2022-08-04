# Orion-Bindings

Framework para realização de Bind via escrita de comandos.
O OrionBindings tem o objetivo de realizar a sincronização de dados através de cada property dos seus objetos para os componentes visuais da sua aplicação e vice-versa.<br>

<b>Extensível:</b> Projetado para ser extensível, conta também com a possibilidade de criar integração com qualquer biblioteca de componentes visuais que você preferir.<br>

<b>Conceito de middlewares</b>: Você mesmo pode escrever seu middleware e integra-lo ao framework de forma simples e rápida.

## Instalação

Para instalar basta registrar no library patch do delphi o caminho da pasta src da biblioteca ou utilizar o Boss (https://github.com/HashLoad/boss) para facilitar ainda mais, executando o comando

```
boss install https://github.com/ricardo-pontes/Orion-Bindings
```

## Como utilizar

É necessário adicionar ao uses do seu formulário as units:

```
Orion.Bindings.Interfaces,
Orion.Bindings;
```
Em seguida, instanciar uma variável do tipo iOrionBindings

```
FBinds := TOrionBindings.New;
```
## Bibliotecas de Componentes Visuais

O OrionBindings foi projetado para ser extensível, o que significa que podemos criar integrações para qualquer biblioteca de componentes visuais que desejarmos.
Atualmente temos integração com alguns componentes visuais da FMX, basta acessar https://github.com/ricardo-pontes/Orion-Bindings-VisualFramework-FMX-Native;

Para que o framework faça a integração com a biblioteca, basta adicionar ao uses do projeto uma biblioteca e passar uma instância para o framework. 
Podemos incluir quantas integrações quisermos, bastando apenas executar o comando Use. Ex:

```
FBinds.Use(TOrionBindingsVisualFrameworkFMXNative.New);
```
## Criando os Binds

Para fazer os binds em componentes, primeiro precisamos informar ao framework o objeto e o formulário.

```
 FBinds.View(Self);
 FBinds.Entity(FCustomer);
```

Feito estas configurações, o framework estará apto para sincronizar as informações, bastando agora informar os binds.

```
FBinds.AddBind('EditID', 'ID');
FBinds.AddBind('EditName', 'Name');
```

## Executando os binds com o Objeto e com o Formulário

Para executar o bind para os componentes visuais basta executar o seguinte comando:
```
FBinds.BindToView;
```
Para executar o bind para o Objeto basta executar o seguinte comando:
```
FBinds.BindToEntity;
```

## Bind em objetos que contem coleções de objetos

Se o Objeto conter uma ou mais coleções de objetos, o framework conta também com binds em coleções do tipo TObjectList, bastando executar os seguintes comandos;
```
FBinds.ListBinds.Init;
FBinds.ListBinds.ComponentName('ListView1');
FBinds.ListBinds.ObjectListPropertyName('Contacts');
FBinds.ListBinds.ClassType(TContact);
FBinds.ListBinds.Primarykey('ID');
FBinds.ListBinds.AddListBind('ID', 'ID');
FBinds.ListBinds.AddListBind('Description', 'Description');
FBinds.ListBinds.Finish;
```
No Exemplo acima, no Objeto Customer existe uma property chamada "Contacts" que é um TObjectList<TContact>;
Todos os parâmetros são obrigatórios para a execução dos binds e você não precisa se preocupar com o estado dos objetos, o próprio framework se encarregará do sincronismo entre o formulário de dados e a coleção, ficando responsável pelas alterações, inserções e exclusões.

Também é possível fazer bind apenas com coleção de objetos que estão separadas da entidade principal.
 
```
FBinds.ListBinds.Init(True); //True é para informar que o objeto é um bind separado da entidade principal
FBinds.ListBinds.ComponentName('ListView1');
FBinds.ListBinds.ObjectList(FSeparatedContacts);
FBinds.ListBinds.AddListBind('ID', 'ID');
FBinds.ListBinds.AddListBind('Description', 'Description');
FBinds.ListBinds.Finish;
```
## Middlewares nos Binds

O framework conta com o conceito de middlewares nos binds, no qual serão executados antes do bind acontecer, tendo assim a capacidade de interceptar o valor caso seja um BindToView ou um BindToEntity e dando a flexibilidade para que qualquer pessoa possa escrever o seu próprio middleware, de acordo com a sua necessidade.

### Requisitos
Apenas dar uses dos middlewares no formulário e passar em um array no bind desejado.

```
FBinds.AddBind('EditSalary', 'Salary', [FormatCurrency]);
FBinds.AddBind('EditCPFCNPJ', 'Document.Number', [CPF, CNPJ]);
```
No exemplo acima, foram passados 3 middlewares que serão responsáveis por fazer a formatação da informação no componente visual, tendo este efeito:

![Middleware 1](https://github.com/ricardo-pontes/Orion-Bindings/blob/main/assets/Sem%20t%C3%ADtulo.png)

Nota: Os middlewares CPF e CNPJ verificam o tamanho do conteúdo que veio da property do objeto, para assim ser executado, sendo assim, se o conteúdo tiver Length = 11, o CPF será executado e se tiver Length = 14, o CNPJ será executado. Por isso, o middleware de CPF foi executado e o de CNPJ não, existe esta condição em ambos.

## Middlewares Oficiais

Criou o seu próprio middleware e quer disponibilizar para a comunidade? envie um PR que colocaremos na nossa lista de middlewares

https://github.com/ricardo-pontes/Orion-Bindings-Middleware-FormatCurrency<br>
https://github.com/ricardo-pontes/Orion-Bindings-Middleware-ZeroIfEmptyStr<br>
https://github.com/ricardo-pontes/Orion-Bindings-Middleware-CNPJ<br>
https://github.com/ricardo-pontes/Orion-Bindings-Middleware-CPF<br>

