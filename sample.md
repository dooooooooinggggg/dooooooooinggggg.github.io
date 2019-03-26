あくまで自分用のメモ。

今後の実装の時に、簡単に振り返るための記事。

[プログラマは皆どのようにしてLisperと化して行くのか?](http://valvallow.blogspot.jp/2010/03/lisper.html) <- この記事を読んで興味を持ったのが始めようと思ったきっかけ。

進めている本は、`Land Of Lisp`



[asin:4873115876:detail]



## 所感

今までのどんな言語とも書き方が違う。

イメージでは、各命令は、シェルスクリプトの、コマンドのような印象を受けた。

あとは、全てがリストである。

この二つを意識して、書いて行きたい。

## defparameter

グローバル変数を定義する。

このような変数を、ドップレベル定義と呼ぶ。

これを使って定義された変数は、同じようにまた`defparameter`が使われると上書きされる。

```lisp
(defparameter *foo* 5)
```

## defvar

こちらは、上と違って、定義した変数の値が変更されない。


```lisp
(defvar *foo* 5)
```



## let

local変数の定義、ブロック内でのみ有効。

```lisp
(let ((a 5)
    (b 6))
    (+ a b))
```

## flet

local関数の定義、ブロック内でのみ有効。

```lisp
(flet (
    (f (n)
        (+ n 10))
    )
    (f 5))
```

書式は、

```lisp
(flet ((関数名 (引数)
    関数本体...s))
    本体....)
```

;; ブロックの初めで、関数を定義する(fという名前)
;; これを、処理本体で、利用している。

;; 一つのfletコマンドで、複数のローカル関数を一緒に宣言するには、単にコマンドの最初の部分に複数の宣言を書く。

```lisp
(flet (
    (f (n)
        (+ n 10))
    (g (n)
        (- n 3)))
    (g (f 5)))
```

## labels

ローカル関数の中で、同じスコープで定義されるローカル関数名を使用したい場合は、labelsコマンド

形式は fletと同じ

再帰？

```lisp
(labels (
    (a (n)
        (+ n 5))
    (b (n)
        (+ (a n) 6)))
    (b 10))
```

出力->21

## 比較

```lisp
;; eq
(eq 'fooo 'foOo)
;; T
```

要は、大文字と小文字を区別しない。

## 関数を食べる関数

```lisp
;; 関数を食べる関数
(defun my-length(list)
    (if list
        (1 + (my-length (cdr list)))
        0))

(my-length '(list with four symbols))
```

再帰の簡単な実装。

## car cdr

`car`は、リストの一番目の要素を取り出す、リスト関数。

`cdr`は、リストの二番目以降を取り出す、リスト関数。

これらは、組み合わせて使って行くことができる。

caadadarみたいな使いかたもできる。

これらを内部で組み合わせた関数もたくさんある。

## コードモード データモード

\`をつけることで、データモードになる。

,をつけることで、データモードの中でも、一時的にコードモードになる。

## if

```lisp
(if ( = ( + 1 2) 3)
    'yup
    'nope)

(if ( = ( + 1 2) 4)
    'yup
    'nope)
```

やるべきではないかもしれないが、これをC言語で書いてみると、

```c
if ( (1 + 2) == 3 ){
    return 1;
}else{
    return 0;
}

if ( (1 + 2) == 4 ){
    return 1;
}else{
    return 0;
}


```

このようになる。

## progn

```lisp
(defvar *number-was-odd* nil)

(if (oddp 5)

    ;; 本来ifでは一つのことしかできないが、prognを使って、複数のことをしている。
    (progn(setf *number-was-odd* t)
        'odd-number)
    'even-number)

*number-was-odd*

```

コメントアウトにもあるように、通常、ifでは、一つのことしかできないが、`progn`を使うことで、複数のことができるようになる。

## when unless

```lisp
(defvar *number-is-odd* nil)

;; ifではなく、whenを使うことによって、暗黙のprogn
(when (oddp 5)
    (setf *number-is-odd* t)
    'odd-number)

*number-is-odd*

(unless (oddp 4)
    (setf *number-is-odd* nil)
    'even-number)

*number-is-odd*

```

if文では、通常、評価がtrueだった場合には、その式しか実行されない(当然)

lispでは、whenを使うことで、暗黙のprognとなる。(イメージ的には、`if (true) {hoge....}`)

その逆の`unless`は、`if (false) {hoge....}`のような感じ。

## cond

condは、カッコをたくさん使う代わりに、三目のprognが使えて、複数の分岐もかける。
それに加えて、続けていくつもの条件を評価することもできる。

```lisp
(defvar *arch-enemy* nil)

(defun pudding-eater (person)
    (cond ((eq person 'henry) (setf *arch-enemy* 'stupid-lisp-alien)
            '(curse you lisp alien - you ate my pudding))
        ((eq person 'johnny) (setf *arch-enemy* 'unless-old-johnny)
            '(i hope you choked on my pudding johnny))
        (t '(why you eat my pudding stranger?))))

(pudding-eater 'johnny)
;; (I HOPE YOU CHOKED ON MY PUDDING JOHNNY)

*arch-enemy*
;; UNLESS-OLD-JOHNNY

(pudding-eater 'geroge-clooney)
;; (WHY YOU EAT MY PUDDING STRANGER?)

(pudding-eater 'henry)
;; (CURSE YOU LISP ALIEN - YOU ATE MY PUDDING)
```

## case

他の条件分岐として、

```lisp
(defun pudding-eater (person)
    (case person
        ((henry) (setf *arch-enemy* 'stupid-lisp-alien)
            '(curse you lisp alien - you ate my pudding))
        ((johnny) (setf *arch-enemy* 'useless-old-johnny)
            '(i hope you choked on my pudding johnny))
        (otherwise '(why you eat my pudding stranger ?))))
```

このように、`case`を使うことができる。

## member

```lisp
(if (member nil '(3 4 nil 6))
    'nil-is-in-the-list
    'nil-is-not-in-the-list)

(if (member nil '(3 4 nil))
    'nil-is-in-the-list
    'nil-is-not-in-the-list)

```

memberを使うことで、ある要素が、そのリストに含まれているかを確認することができる。

しかし、ここが少し特殊で、

```lisp
(member 1 '(3 4 1 5))
```

とすると、かえってくる値は、trueではなく、

```lisp
;; (1 5)
```

となる。

こうなる理由に関しては、本を読んでもらえればわかるが、lispの条件の評価の仕方によるものである。

lispが偽であると判定する値には、実は4種類しかない。

## 偽

```lisp
'()
()
'nil
nil
```

以上の4こを除き、全て真となる。つまり、それぞれの関数は、真である、という情報以外に、好きなものを返すことができる。

また、上の例でいうと、もしこの`member`が見つけたリスト自身を返した場合、

通常は上手く行くが、

```lisp
(if (member nil '(3 4 nil 6))
    'nil-is-in-the-list
    'nil-is-not-in-the-list)
```

この例でいくと、`nil`が返ってきてしまい、あるにもかかわらず、結果が、偽と判定されてしまう。

しかし、この実装のおかげで、返ってくる値は、nilではなく、(nil 6)、もしnilが最後の要素だったとしても、

(nil)が返ってくるため、真と判定できる。

## eq

```lisp
;; シンボル同士は、eqで比較する。
(defparameter *fruit* 'apple)

(cond ((eq *fruit* 'apple) 'its-an-apple)
    (eq *fruit* 'orange) 'its-an-orange)

;; シンボル同士で、eqを使えるのに、eqを使わないのは、いけてない

;; シンボル同士の比較
(equal 'apple 'apple)
;; T

;; リスト同士の比較
(equal (list 1 2 3) (list 1 2 3))
;; T

;; 異なる方法で作られたリストでも、中身が同じなら、同一とみなされる。

;; 整数同士の比較
(equal 5 5)


;; eqlとか、equalpなどは、紛らわしい。

;; ここら辺は後で調べに帰って来ればいいか。
```

lispには、等しいかどうかを調べる関数が、4つほどある。上に書いた通りで、それぞれ微妙に条件が異なる。

## まとめ

今まで触ったどんな言語とも書き方が異なるため、写経を積極的に行なっている。

書かないと、本当に意味がわからない。

その時に書いて理解してみたものをここに書き連ねたため、漏れなどもあるかもしれない。

今後実装を進めていく際に、必要になりそうだったら、この記事に追記して行きたい。

続き↓



[http://blog.ishikawa.tech/entry/2018/04/19/030157:embed:cite]






