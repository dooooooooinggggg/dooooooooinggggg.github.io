# 前提条件

- 独自ドメインを持っている

- Cloudflareのアカウント

- Githubのアカウント

# 手順

## Githubにて、リポジトリを作成する。

Githubにて、リポジトリを作成する。

この時、`"ユーザー名" +.github.io`という名前にする。(例えばユーザー名が、aaaだったら、`aaa.github.io`)

また、リポジトリは、`public`にする。つまり、オープンソースの静的なサイトということ。

## 内容を作る。

内容を作る。

この時点で、もうすでに作ったURLにはアクセスできる。

デフォルトでは、READMEの内容(MarkDownをレンダリングしたもの)が公開されている。

自分の場合は、HTMLを書くのが面倒だったため、そのまま`README.md`をそのまま拡張していった。

この場合は、`<head></head>`などの要素は自動で生成される。

また、仮に、`index.html`を作成した場合、そっちが優先される。この場合、`<head></head>`などの要素は自分で書かねばならない。

## デザインを変更し、CNAMEを登録する。

リポジトリの上部メニュー

`Code  Issues  Pull requests  Projects  Wiki  Insights  Settings`

となっているところから、`Settings`を選択する。

下の方に行くと、`Change Theme`となっているところがある。

ここを押してテーマを選ぶ。そんなに種類はないが、MarkDownで書いたページならこのデザインを適用してくれる。

また、その下にある、`Custom domain`というところに、自分の独自ドメインを登録する(プロトコルはいらない)。

この記事を書いている時点で、Githubのみで、独自ドメインかつhttpsを実現するのは厳しそう

```
Unavailable for your site because you have a custom domain configured
```

みたいなメッセージが出る。

そこで、CloudFlareを使う。

もしまだDNSがCloudFlareになっていない人がいたら、移管させておく。

ドメインの登録ができたら、レコードの登録をしていく。

自分の場合は、諸事情により、wwwと無印でアクセス先が異なるため、今回は無印のみの登録。

`CNAME ishikawa.tech dooooooooinggggg.github.io`

で、登録完了。この時、`HTTP Proxy`を`ON`にしておく。

## CloudFlareでのCryptoの設定

項目ごとに、パラメータを紹介する。

### SSL

```
Full
```

### Edge Certificates

いじらない。

### Always use HTTPS

```
On
```

### HTTP Strict Transport Security (HSTS)

```
Status: On
Max-Age: 6 months (recommended)
Include subdomains: Off
Preload: On
No-sniff: On
```

### Authenticated Origin Pulls

```
On
```

### Require Modern TLS

```
On
```

### Opportunistic Encryption

```
On
```

### Automatic HTTPS Rewrites

```
On
```

## Page Rules

httpにアクセスがきたら、httpsに転送するように、かく。

```
http://ishikawa.tech
-> Always Use HTTPS
```

以上で、設定は完了。少し反映に時間がかかるが、しばらくすると、無事`https`なサイトが公開されている。

[https://ishikawa.tech](https://ishikawa.tech)
