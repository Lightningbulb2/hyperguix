;;; GENERATED FILE -- do not edit by hand.
;;; Regenerate with the scripts in contrib/ when the upstream lockfiles change.

;;; npm registry tarballs needed to build the web front ends of the Tauri
;;; applications, taken from each upstream lockfile (package-lock.json or
;;; pnpm-lock.yaml) and restricted to what installs on x86_64-linux.  Each
;;; entry is (REGISTRY-PATH . ORIGIN); see (Lightningbulb packages js-offline).

(define-module (Lightningbulb packages node-deps)
  #:use-module (Lightningbulb packages js-offline)
  #:export (scrcpy-gui-npm-tarballs
            faforever-client-npm-tarballs
            faforever-client-pnpm-tarball))

(define scrcpy-gui-npm-tarballs
  (list (npm-tarball "@adobe/css-tools/-/css-tools-4.4.4.tgz"
                     "0y643vi7msx2psshd0vhd18r42bv5s4gvcfwi68a98y8dsslls0n")
        (npm-tarball "@alloc/quick-lru/-/quick-lru-5.2.0.tgz"
                     "0fkxm7kqyid4zydqks1s294lgiyjb534b1qvrlil9f5c1z8mp7sm")
        (npm-tarball "@asamuzakjp/css-color/-/css-color-5.1.11.tgz"
                     "030zp439808pmy4jan9666hqdvhpvrdnddx4mg1dpamz0rbjmm9g")
        (npm-tarball "@asamuzakjp/dom-selector/-/dom-selector-7.1.1.tgz"
                     "17wivlzzaa1778h29h0agi2j1mfh3k2m2vkpd3fri9rdc6nmbi2m")
        (npm-tarball "@asamuzakjp/generational-cache/-/generational-cache-1.0.1.tgz"
                     "1jr0vsb5r3adzw3l0cdk2xn5v268p032hx08y0vswrh34ydiwald")
        (npm-tarball "@asamuzakjp/nwsapi/-/nwsapi-2.3.9.tgz"
                     "0jix8cpadd4nrrfc0g3riq4ncw96g39ninpxwxs575ag552y7x0i")
        (npm-tarball "@babel/code-frame/-/code-frame-7.29.0.tgz"
                     "180cm49p4zjy0i3blv8vbv6dnwh4bhg99i85361zndc8xkyj3nd4")
        (npm-tarball "@babel/helper-validator-identifier/-/helper-validator-identifier-7.28.5.tgz"
                     "1mfy0jq815jbg68qkbg80jgxl7qicg5q0v4dkj31d3766bk13356")
        (npm-tarball "@babel/runtime/-/runtime-7.29.2.tgz"
                     "1rc71zqm9k7cwhhqrn7v0njgk04vw5ppznlbbshcq545kskdvmli")
        (npm-tarball "@bramus/specificity/-/specificity-2.4.2.tgz"
                     "084frp65fgl17zvf0br979drjxghiar77knzf7m8bn9ybpf1x3qx")
        (npm-tarball "@csstools/color-helpers/-/color-helpers-6.0.2.tgz"
                     "0pvydlr2qb5wsgp3438awy5saw9zpg5h76kwysv6r286s2z3x2sl")
        (npm-tarball "@csstools/css-calc/-/css-calc-3.2.0.tgz"
                     "08zdqldq36wmpsfjzy3r4k1spj0lrxrd38bk0lsw4b2wm6g4y30w")
        (npm-tarball "@csstools/css-color-parser/-/css-color-parser-4.1.0.tgz"
                     "1rvnmllmd350ln3wjvvy77p7g3vgy025sc09481gxchsx2vpnrjb")
        (npm-tarball "@csstools/css-parser-algorithms/-/css-parser-algorithms-4.0.0.tgz"
                     "1v9dks12fhj3jckg8l09yl850crcr1rxflyqcx7hzsyf1v5kc6pz")
        (npm-tarball "@csstools/css-syntax-patches-for-csstree/-/css-syntax-patches-for-csstree-1.1.3.tgz"
                     "1picmvir3sb4m7prj5yxddis66bp796zxchkf3z08dx7vbcwhy64")
        (npm-tarball "@csstools/css-tokenizer/-/css-tokenizer-4.0.0.tgz"
                     "16dkigl6flp2sb005269xl8fmwzkppl9f26lz7mwvg75gz5lr7jg")
        (npm-tarball "@emnapi/core/-/core-1.10.0.tgz"
                     "08575269hy74mc0kgfilsr49gw6fj80zmrdacwx707r3fch62d38")
        (npm-tarball "@emnapi/runtime/-/runtime-1.10.0.tgz"
                     "1s000zngg031kfjw0m7p39p2zcwf9w4jvi2f24ss1pj722198blc")
        (npm-tarball "@emnapi/wasi-threads/-/wasi-threads-1.2.1.tgz"
                     "1fcbx8f56gmnzngg864an4yk6n8y9f9ck7jpayixnbnijszf7r1h")
        (npm-tarball "@exodus/bytes/-/bytes-1.15.0.tgz"
                     "1db7wxfgqfsng683br785gf4sdpffdnxp3k0dz74rcgd7349s83n")
        (npm-tarball "@jest/diff-sequences/-/diff-sequences-30.3.0.tgz"
                     "0hr06d8mvb4896vrxyrmfkby3ygajc5dj4c815bk156561dxq9p6")
        (npm-tarball "@jest/expect-utils/-/expect-utils-30.3.0.tgz"
                     "0n7v0hd2symj83y9fbph0c57as0pf5l0rzji70qmryaxcw1wl7il")
        (npm-tarball "@jest/get-type/-/get-type-30.1.0.tgz"
                     "1pjhl678kl7ssqh99mf7jhjaqvk7g1nhgw26dlqd68x0n96vsy9p")
        (npm-tarball "@jest/pattern/-/pattern-30.0.1.tgz"
                     "0wk8rl253pn4i4x1kvdrjp2yk2icf98jnrxdlmnp0njfxmgyizdp")
        (npm-tarball "@jest/schemas/-/schemas-30.0.5.tgz"
                     "17gq13949bz39y3hwsakcjjqg0bdqxg4988nsm62ccwbra43h6dd")
        (npm-tarball "@jest/types/-/types-30.3.0.tgz"
                     "1adhcd9bs33vakc49xjp5yxj3x3gpdlqq1ai613mbcrq37lkbf55")
        (npm-tarball "@jridgewell/gen-mapping/-/gen-mapping-0.3.13.tgz"
                     "10h05zv5qcbxiz5wslzqv1aik7zl0cfqiarqhw63xmpnq5cgc5mw")
        (npm-tarball "@jridgewell/remapping/-/remapping-2.3.5.tgz"
                     "00hssw2k05fxp4fgjk9182bgynx2b4slfcvwwir6dlcslf16gcbh")
        (npm-tarball "@jridgewell/resolve-uri/-/resolve-uri-3.1.2.tgz"
                     "0c72fqvljvr28rdmg6hjd8zc63vm00r9xlrx6l9spfjq4pvgjlnv")
        (npm-tarball "@jridgewell/sourcemap-codec/-/sourcemap-codec-1.5.5.tgz"
                     "11b5h4hihb2n8203znalqm53s7pv82a84jahsqgf7rd2406kpba7")
        (npm-tarball "@jridgewell/trace-mapping/-/trace-mapping-0.3.31.tgz"
                     "1krw8nqmca9k4gb20kh9mpfsjb2b6ggrx226haz5l3b336hp2k66")
        (npm-tarball "@napi-rs/wasm-runtime/-/wasm-runtime-1.1.4.tgz"
                     "020blrp8ci6k73r89v44r2b982igqrs4si0rk8pqv3zx6frq314n")
        (npm-tarball "@oxc-project/types/-/types-0.127.0.tgz"
                     "0ls7jnfrjnsa8d1nj12c2hfm0d58qsj0yh5g177yc9cfph606kgy")
        (npm-tarball "@rolldown/binding-linux-x64-gnu/-/binding-linux-x64-gnu-1.0.0-rc.17.tgz"
                     "0lgicw7xf4vckb7yj6cmr5jnzlvcgw9fgdx1x87lml40ka9g6gds")
        (npm-tarball "@rolldown/binding-linux-x64-musl/-/binding-linux-x64-musl-1.0.0-rc.17.tgz"
                     "0qqhg487m42ppd7lbllkhcnq5j4d5abkslx1cxv7gs6694z29nkl")
        (npm-tarball "@rolldown/pluginutils/-/pluginutils-1.0.0-rc.17.tgz"
                     "1ynmkfs2g05wagzw9zz5al7l5vwlbpski2fc11wdrnxqd3md1mny")
        (npm-tarball "@rolldown/pluginutils/-/pluginutils-1.0.0-rc.7.tgz"
                     "1j3scm70mzb6y8v3fi7d60qkb9lsh7hbzcl0k12rz82ppagap4by")
        (npm-tarball "@sinclair/typebox/-/typebox-0.34.49.tgz"
                     "1x59k0vqdk2ymhplqx21f5da6p7jz6667hwjd4986gv3wm0hx97s")
        (npm-tarball "@standard-schema/spec/-/spec-1.1.0.tgz"
                     "1byfgh3b6ngdj4vba2jw48bk9wl6gjqc7y2hshcba2i8prl75jx7")
        (npm-tarball "@tailwindcss/node/-/node-4.2.4.tgz"
                     "15631fcgavd04dkp3brj9jjf4q5vnvxrvafq5fy7lb1w40kkczpw")
        (npm-tarball "@tailwindcss/oxide-linux-x64-gnu/-/oxide-linux-x64-gnu-4.2.4.tgz"
                     "1jkqpx2bxc30wdgy601al24nqsi055c1vhvb1pfd567zhnnzg2fc")
        (npm-tarball "@tailwindcss/oxide-linux-x64-musl/-/oxide-linux-x64-musl-4.2.4.tgz"
                     "00rq1fill269xx3l40byj24pdmlz63c6dwa6d1na0752x4bh1awl")
        (npm-tarball "@tailwindcss/oxide/-/oxide-4.2.4.tgz"
                     "15sjvi1qy9s4pvbxy91phxkbhs1rkd5qpmbmaagfc16i8il3qkp5")
        (npm-tarball "@tailwindcss/postcss/-/postcss-4.2.4.tgz"
                     "1jqqy2rcng7dybprgkql0h2h5lxg9i729lwv39qp6hpmkdfaiivk")
        (npm-tarball "@tauri-apps/api/-/api-2.10.1.tgz"
                     "1hygkrir7iqgkspwdk0pynp6z5qicja6g43jv98nmvv5za4xzvy6")
        (npm-tarball "@tauri-apps/cli-linux-x64-gnu/-/cli-linux-x64-gnu-2.10.1.tgz"
                     "101lg49m623cgbnw8fcynzl60a24w184h94ahwd2s6jg0wpxhblm")
        (npm-tarball "@tauri-apps/cli-linux-x64-musl/-/cli-linux-x64-musl-2.10.1.tgz"
                     "1kgizbxyrbw7hy39bykzyq94270p4c6567b31zd1iniwa8dys3i1")
        (npm-tarball "@tauri-apps/cli/-/cli-2.10.1.tgz"
                     "0pnzicjkni825l3j03a43byh16mp4rqv75w3r44nva37sdlrhjg5")
        (npm-tarball "@tauri-apps/plugin-dialog/-/plugin-dialog-2.7.0.tgz"
                     "1jkzsfk3a0kdz215sgqnq4slrx96pz4dcpbm8i6kgc1lawbqfkpv")
        (npm-tarball "@testing-library/dom/-/dom-10.4.1.tgz"
                     "0hm73d8mpckyraxjjiy6xajlp6a8rlmjd7zx0va2nbfzs77a57jr")
        (npm-tarball "@testing-library/jest-dom/-/jest-dom-6.9.1.tgz"
                     "1cb9xrdd4rz0fs4mdgryjwiswfpmyjaqrhjdj6nzd6cmiqjsnlpf")
        (npm-tarball "@testing-library/react/-/react-16.3.2.tgz"
                     "1sbgxsgzxlrdxax2n3zgwh97xkmal824g9ilp081piqjg3k3bb50")
        (npm-tarball "@testing-library/user-event/-/user-event-14.6.1.tgz"
                     "140a7yz8a6rmff5398pncblkivkfw4jy57hkxsy5lykawbvgpg1d")
        (npm-tarball "@tybys/wasm-util/-/wasm-util-0.10.1.tgz"
                     "1fyznbqc5cznj67a6njm67cdqn46yq16wc395mw4ji0x13kbvj1d")
        (npm-tarball "@types/aria-query/-/aria-query-5.0.4.tgz"
                     "1j569fqjjymh1zbixnyba6qibx5s10dj6bwxywlfa0sjxx5p0m6l")
        (npm-tarball "@types/chai/-/chai-5.2.3.tgz"
                     "153zvpnbwgi62h75w9jzcjpayr87af2rnvidk8npvq9q8bim432z")
        (npm-tarball "@types/deep-eql/-/deep-eql-4.0.2.tgz"
                     "01rnbz1kbwyrs8bh1ljzqajcbx1d6h82pcb2d6yj68ndy9gihgdn")
        (npm-tarball "@types/estree/-/estree-1.0.8.tgz"
                     "0jnm82j29n0mm527qsz7rv05sksxkgsa92c54f96mnijf7mm611r")
        (npm-tarball "@types/istanbul-lib-coverage/-/istanbul-lib-coverage-2.0.6.tgz"
                     "149v0pm6i23zdipmi2kharzscnwh8jh9vpbm7pcgrnjpw1s7bmls")
        (npm-tarball "@types/istanbul-lib-report/-/istanbul-lib-report-3.0.3.tgz"
                     "1m44676lbdsib8zrha7x629rs3ypa1q55iyrd9wv7z6243vz26r6")
        (npm-tarball "@types/istanbul-reports/-/istanbul-reports-3.0.4.tgz"
                     "0ndqq2z7jmja1fwsiymb2kh7grr73jdl029nvz4ihd0xmcyfg6h5")
        (npm-tarball "@types/jest/-/jest-30.0.0.tgz"
                     "0fn5kvlrb0dcsl7m1qf2jilg8cv60qk25zq9ar56hxn2jjxkm809")
        (npm-tarball "@types/node/-/node-25.6.0.tgz"
                     "0cmd1xszs1bfn4vgdahk4yv4b5rk02yykd7542jplif1b2r33mpv")
        (npm-tarball "@types/react-dom/-/react-dom-19.2.3.tgz"
                     "0jqdpwav9lmsxiq5s9218vgx1s3972idzbnxb4fyc5pnwwqnjxh1")
        (npm-tarball "@types/react/-/react-19.2.14.tgz"
                     "1lmrdnw8vpymmvmxpcar92y5bmi1cwqxai5kdi6wkla0id9wy3gf")
        (npm-tarball "@types/stack-utils/-/stack-utils-2.0.3.tgz"
                     "04lq0zvkykfxm378wqy9ly0h30vhqngvxssmq26mz889jqc980sj")
        (npm-tarball "@types/yargs-parser/-/yargs-parser-21.0.3.tgz"
                     "1h2v9y5ivyvk67np73fl2hkbbvfr4af680nf390akmsrykqjsxnv")
        (npm-tarball "@types/yargs/-/yargs-17.0.35.tgz"
                     "043rv0fx4fxa85w5zcinn3qjbphyric8d71zyd0qgnv7jja739cc")
        (npm-tarball "@vitejs/plugin-react/-/plugin-react-6.0.1.tgz"
                     "0lv1i452fbnrb6f23dfz3037jj3ir5yaii8p0k14wcwcnidjhrjd")
        (npm-tarball "@vitest/expect/-/expect-4.1.5.tgz"
                     "1p9qjrfk313kwx1xb6nchpzl030p1d4825zdwz5qzy3v1h15kmlq")
        (npm-tarball "@vitest/mocker/-/mocker-4.1.5.tgz"
                     "178j62wfvj7ggrwpvy1jh1h8mhgk49bb1r520hdd1xdxn9w3pf5w")
        (npm-tarball "@vitest/pretty-format/-/pretty-format-4.1.5.tgz"
                     "12117lfzmby1dkmrx7aq5zph1qwwx194gsgl8k3s75ia4w7ja3xs")
        (npm-tarball "@vitest/runner/-/runner-4.1.5.tgz"
                     "1jzfxkgab33wd4rx140gjkhpia8ir27hvq53i0sfij4hgzcp294d")
        (npm-tarball "@vitest/snapshot/-/snapshot-4.1.5.tgz"
                     "0d72vc8889dc18qpjirh3xxcx1sy5rj097kbxr5ddgwzcy6arv34")
        (npm-tarball "@vitest/spy/-/spy-4.1.5.tgz"
                     "1idf1x76sc2cc4sxj14861qyh59zbjscm4r3fncyazgkl702fm5a")
        (npm-tarball "@vitest/utils/-/utils-4.1.5.tgz"
                     "16zq0z2sgxzqa11lydr0m7arqbh6k3iwgrv3f0f80in54g8150r5")
        (npm-tarball "ansi-regex/-/ansi-regex-5.0.1.tgz"
                     "1ng0r2k4mcz7b2bfr6g1dschnxm0vifaslsvv2smv06smb6ss3hf")
        (npm-tarball "ansi-styles/-/ansi-styles-4.3.0.tgz"
                     "0zwqsx67hr7m4a8dpd0jzkp2rjm5v7938x4rhcqh7djsv139llrc")
        (npm-tarball "ansi-styles/-/ansi-styles-5.2.0.tgz"
                     "0px0skwhaf4yiwahjba34cr6c5am3b21paab5hnbny8j89h97pad")
        (npm-tarball "aria-query/-/aria-query-5.3.0.tgz"
                     "14jw4f6mbcz16yxbxypvm5133vlz0qkjvcxwvqp41a3819rnsc6a")
        (npm-tarball "assertion-error/-/assertion-error-2.0.1.tgz"
                     "0mhgq8w0jyw6x02gzy3p5zzfaglkly2lv38q4cqlz3mkr6rsbx3k")
        (npm-tarball "autoprefixer/-/autoprefixer-10.5.0.tgz"
                     "0bnw73flxc9gvq7svamqyb3jnzcayd0i9l9xd72qyfpi7jlagc0p")
        (npm-tarball "baseline-browser-mapping/-/baseline-browser-mapping-2.10.24.tgz"
                     "1h35qnjq4zqyi8di06gdm0ssb38kkbwvf6bsklh60d8r73rznkq8")
        (npm-tarball "bidi-js/-/bidi-js-1.0.3.tgz"
                     "1llccna16374xx10yg6r8b410dc6d3d5fbimc2v841zlf6q5kk57")
        (npm-tarball "browserslist/-/browserslist-4.28.2.tgz"
                     "1a5vyfxsjl9hz14g9y6x6k071hxkn5lb3frwqs8chpmjb46f9b42")
        (npm-tarball "caniuse-lite/-/caniuse-lite-1.0.30001791.tgz"
                     "0bynfhfjlzsx98mlhdqvmi36md8myhj1m06si9id6awfl49yszmr")
        (npm-tarball "chai/-/chai-6.2.2.tgz"
                     "0n2v0njbnmqdxvwzfb55fg6lbd5ybbsm4sz9k1hwaiak6xsdab3h")
        (npm-tarball "chalk/-/chalk-4.1.2.tgz"
                     "02prgl8d52k2vgxnssx06ha2sjm2vp6v6s6kqgkar1ryllx68k78")
        (npm-tarball "ci-info/-/ci-info-4.4.0.tgz"
                     "07srv966n8h2lryysjmr2sig8gfwxnan27mgr17kbw7j99093p4h")
        (npm-tarball "color-convert/-/color-convert-2.0.1.tgz"
                     "1qbw9rwfzcp7y0cpa8gmwlj7ccycf9pwn15zvf2s06f070ss83wj")
        (npm-tarball "color-name/-/color-name-1.1.4.tgz"
                     "020p7x7k8rlph38lhsqpqvkx0b70lzlmk6mgal9r9sz8c527qysh")
        (npm-tarball "convert-source-map/-/convert-source-map-2.0.0.tgz"
                     "160qzrwfhj8xkc2ya476hp7sahaj5gnzv4hi6xl9zq74qwz2bxqp")
        (npm-tarball "css-tree/-/css-tree-3.2.1.tgz"
                     "02mfzz1vklyj68ff481ym2vbcbiv1a7cy3879hx101nh6gkvy1jc")
        (npm-tarball "css.escape/-/css.escape-1.5.1.tgz"
                     "0bp2h71klppwlhwssq1xq8d80wm9y0ljra3grqwk7zw43h12fp76")
        (npm-tarball "csstype/-/csstype-3.2.3.tgz"
                     "18r7fhq1k5apllflcqljwmkh8b0n649c28nbzrl7agy7w671yl7k")
        (npm-tarball "data-urls/-/data-urls-7.0.0.tgz"
                     "1x5kdhw11m3ard6bss40pvz24vwm765c88sliwiax4ny75y938br")
        (npm-tarball "decimal.js/-/decimal.js-10.6.0.tgz"
                     "1cbis3kaiwbznnm3an1wbbqyawh8rsq58k05chprfjc15q910cj3")
        (npm-tarball "dequal/-/dequal-2.0.3.tgz"
                     "0dawdan67ns9pdm629n8mh9zmy7qdn65v86j21yicy4qcbb907cl")
        (npm-tarball "detect-libc/-/detect-libc-2.1.2.tgz"
                     "09wlldyqvhf2w7q4xcch4xh6pvldy7c2vbx83m48dzvcq07yq397")
        (npm-tarball "dom-accessibility-api/-/dom-accessibility-api-0.5.16.tgz"
                     "0a5qbgx92nzi8salzwx917sw0jbcp9fzgca3khm4c453qdvphrnf")
        (npm-tarball "dom-accessibility-api/-/dom-accessibility-api-0.6.3.tgz"
                     "0cchm5l9gd0raixjsd6j6za8k6dn74xwh3fd5anyvkzk4mry5g4h")
        (npm-tarball "electron-to-chromium/-/electron-to-chromium-1.5.344.tgz"
                     "0m9h3hwn0g08402crprpv88r8n4prgf9qz73n5lxmninalszlsxf")
        (npm-tarball "enhanced-resolve/-/enhanced-resolve-5.21.0.tgz"
                     "0q32g5wx0ixh57n0r566fbx8xgxwwr0dlhr0jywvll1c0j62i4ms")
        (npm-tarball "entities/-/entities-8.0.0.tgz"
                     "0ny2ih3ll9jcy0w5lxp6id19jggql0cgaxcz1z42zh8riqw1d2wf")
        (npm-tarball "es-module-lexer/-/es-module-lexer-2.1.0.tgz"
                     "0dvqhbpmh7wxn7pyfx6ka899pm26llbc8r4hpw9sdcfnvmir4nki")
        (npm-tarball "escalade/-/escalade-3.2.0.tgz"
                     "1rxy0388xsgxam8limnbxhksa1z1xccd47vi4r9p1ip6q2pma9xs")
        (npm-tarball "escape-string-regexp/-/escape-string-regexp-2.0.0.tgz"
                     "05ivsfsg6yc214fw0r8kaf3590jfvgl81m5l1n5ivxcpyv0xpn3m")
        (npm-tarball "estree-walker/-/estree-walker-3.0.3.tgz"
                     "1cvj3jfzlrg1dskkcwbjaccc00s16jma8mag8yg0kvyrdk0zvgdv")
        (npm-tarball "expect-type/-/expect-type-1.3.0.tgz"
                     "0fgj240ahldn8wmrkb7f32hxm4nmqvgd51y45ah3d0a2c30mnxrg")
        (npm-tarball "expect/-/expect-30.3.0.tgz"
                     "1489gpwp9i33r01i6ns34m5xqgjc2ag7i0zawai9d7ff2dkb96ds")
        (npm-tarball "fdir/-/fdir-6.5.0.tgz"
                     "0pin1ngw51v3z7q8gs4q84bwwcw3pdyh29jk8351yahyygcxq794")
        (npm-tarball "fraction.js/-/fraction.js-5.3.4.tgz"
                     "0951aj5ci888vr4a6w8zpr53afcpsd8zrgp42cg591fjba73vqi7")
        (npm-tarball "graceful-fs/-/graceful-fs-4.2.11.tgz"
                     "1709vla02prpbf34xqsvkqngvsmp5ypnljvg1pcgxrk1l553fq9r")
        (npm-tarball "has-flag/-/has-flag-4.0.0.tgz"
                     "1cdmvliwz8h02nwg0ipli0ydd1l82sz9s1m7bj5bn9yr24afp9vp")
        (npm-tarball "html-encoding-sniffer/-/html-encoding-sniffer-6.0.0.tgz"
                     "0ah7rdl2589ia20dmqqqvmm8jcb4n743h573rsa4c0503kpmp857")
        (npm-tarball "indent-string/-/indent-string-4.0.0.tgz"
                     "1822k378f65ipx6v9i132bywcnfjzk3rgilhnp443csfsz9p8sxw")
        (npm-tarball "is-potential-custom-element-name/-/is-potential-custom-element-name-1.0.1.tgz"
                     "08c677pbqjj21h9n6p3m94rmgha0lr3410al6w9sy8k42fxjbr5n")
        (npm-tarball "jest-diff/-/jest-diff-30.3.0.tgz"
                     "1dqvnl6an9b3aw1ks59k5qjan980p3ph13wlvcljb49h98mqmsc8")
        (npm-tarball "jest-matcher-utils/-/jest-matcher-utils-30.3.0.tgz"
                     "1gdv9hrgyfx9d5vawyhjvkmkbyib99sjxkay1wavlnmpaqmi8yq4")
        (npm-tarball "jest-message-util/-/jest-message-util-30.3.0.tgz"
                     "0ni1r4gwvxzpjyrcmkm8f3kgxqrz8i8jjxgy54aq44nggfa8akrw")
        (npm-tarball "jest-mock/-/jest-mock-30.3.0.tgz"
                     "1b55wvc9clc00q93219qh0mmkfkyd570qhvpjd1lxgcywp11fzjs")
        (npm-tarball "jest-regex-util/-/jest-regex-util-30.0.1.tgz"
                     "0z1c1x9hq1y66scn6zjlkjvmwlgp7hhbfpg9lm8mi7xalpk0h5xg")
        (npm-tarball "jest-util/-/jest-util-30.3.0.tgz"
                     "0k38p5a69qd35ld8d91zln0rfbpljw33g3isngndbvar63jw6kps")
        (npm-tarball "jiti/-/jiti-2.6.1.tgz"
                     "1wfm3xw3p88f0ndpy2cdwlirsmjbkl3f4wiak6rc00ny85wgr13r")
        (npm-tarball "js-tokens/-/js-tokens-4.0.0.tgz"
                     "0lrw3qvcfmxrwwi7p7ng4r17yw32ki7jpnbj2a65ddddv2icg16q")
        (npm-tarball "jsdom/-/jsdom-29.1.0.tgz"
                     "113nqd47yz1sv6vbkm14icbgnry8hxdn3578wm1ancqnjfngy1xd")
        (npm-tarball "lightningcss-linux-x64-gnu/-/lightningcss-linux-x64-gnu-1.32.0.tgz"
                     "02ri7hh6c41j3pfvhv9sbpv6pqjqs46mj506nlaa9pfs61i4cvwy")
        (npm-tarball "lightningcss-linux-x64-musl/-/lightningcss-linux-x64-musl-1.32.0.tgz"
                     "11aj18ihs92hg7lg0b7bm3sq8fs70zzpr4yvpzzv82b6di0ay5sj")
        (npm-tarball "lightningcss/-/lightningcss-1.32.0.tgz"
                     "1s2h2ndakhgsjbm9zam4b0fr7l7hi1khlikpb2f437iw47m82gn8")
        (npm-tarball "lru-cache/-/lru-cache-11.3.5.tgz"
                     "06avphrdad992fqz0laf36pvx42w323cxzk0bm234wlfflnc0vvf")
        (npm-tarball "lucide-react/-/lucide-react-0.564.0.tgz"
                     "0pj8l1nzbp3qwgj6si0fybil31i52axhp1pf4z38y91xid2r8iwz")
        (npm-tarball "lz-string/-/lz-string-1.5.0.tgz"
                     "06q1br6dbr8kby28p707pawlsczifhwx7vb6b81whjy5kzvhqr5d")
        (npm-tarball "magic-string/-/magic-string-0.30.21.tgz"
                     "0vv5mh4rnr83gnpd0kkspy1c810f4mfkczrjry64x96wcwjpcjgs")
        (npm-tarball "mdn-data/-/mdn-data-2.27.1.tgz"
                     "0w38wk6ji9sl5m8zk8vdxzrqii2lgwx5qikh5laa1sb4rva5p633")
        (npm-tarball "min-indent/-/min-indent-1.0.1.tgz"
                     "0rq7rb5gkfsrnpx0sazb6b4yln4x1xxhb5x8a9alx2kdrspc19z8")
        (npm-tarball "nanoid/-/nanoid-3.3.11.tgz"
                     "0nc7hkbfjdbmi3k230g11ypvczfv410mrw27wyk4c6xxww1fh64n")
        (npm-tarball "node-releases/-/node-releases-2.0.38.tgz"
                     "145z108hvr1c8mr55p6ghnzyibmxyqqz4nijdnjbiy2gpnjxcjis")
        (npm-tarball "obug/-/obug-2.1.1.tgz"
                     "0hxfqqjcy24n7ibc5rz30iqxxqjjm5jdsjzx407wnj14w2a1g913")
        (npm-tarball "parse5/-/parse5-8.0.1.tgz"
                     "0ck8z21a0lvvl9fn2sdy2pq3hyaxvwhw26h0xjw29vrwdrhchknr")
        (npm-tarball "pathe/-/pathe-2.0.3.tgz"
                     "0dnzjq3529b584wj6rich8p0c16s0ydlbn7miw88lzxvbny76fvf")
        (npm-tarball "picocolors/-/picocolors-1.1.1.tgz"
                     "1nc2z3w16wpz2840srcwyxd747khwfvh66yigyrpwywn0wldpbnk")
        (npm-tarball "picomatch/-/picomatch-4.0.4.tgz"
                     "072pg3ji6ib0ns6jv3ypink59pmfj8432fj82yhxk3jmcsv5lnsi")
        (npm-tarball "postcss-value-parser/-/postcss-value-parser-4.2.0.tgz"
                     "19whda1if07mb56pyqw7y750xclqnaqld82qn92a6rjvz4n3gr9x")
        (npm-tarball "postcss/-/postcss-8.5.12.tgz"
                     "0dd20gxb2rmsm3n6bx4829qm8kk9983v626ki784gbdjn4dpw7sm")
        (npm-tarball "pretty-format/-/pretty-format-27.5.1.tgz"
                     "00s1ld3k7zxx8mxfq8zq49hbnf69z43ggyxjhgipc8f53p4y42zr")
        (npm-tarball "pretty-format/-/pretty-format-30.3.0.tgz"
                     "01yn3160iih3ys6xv8gy6zwrjk6682rbbxz8k22h5vks5zcvh5sv")
        (npm-tarball "punycode/-/punycode-2.3.1.tgz"
                     "1fwkw4ir7gp3i845xv3bj4a4cswgcnmpjwmqpad38i5czgwmkkp4")
        (npm-tarball "react-dom/-/react-dom-19.2.5.tgz"
                     "0q18y9wz1kdv4ahzi7zjbnfwvxyspdkir0hgm19a4c68jd7qfnk3")
        (npm-tarball "react-is/-/react-is-17.0.2.tgz"
                     "1c9yjrjhipdynvkxq035qhd6b9q3l60i482ah6dqxh2gbg05064v")
        (npm-tarball "react-is/-/react-is-18.3.1.tgz"
                     "0ll5j7xqjv680lnv4y99ma9cq1ys5hrx3kb541mpw9zm5sv2nyl6")
        (npm-tarball "react/-/react-19.2.5.tgz"
                     "19f1j0jzxi8kk4g4sclbqf9krgmwcaq6hz7j40w4klrl2gsv5f8x")
        (npm-tarball "redent/-/redent-3.0.0.tgz"
                     "15i8bx7i605yc5l5dhd1bki2f6ssd0inx4r2gdxq9c117pbj9lyq")
        (npm-tarball "require-from-string/-/require-from-string-2.0.2.tgz"
                     "10ldp2bzb86czf47kmvirn9x2976yh6g0my7l1spg3whcm4llsfb")
        (npm-tarball "rolldown/-/rolldown-1.0.0-rc.17.tgz"
                     "1d4ndhsq1wszv4288lxkpilsa7vp8zwslc9khhhgmww4xcvfza0b")
        (npm-tarball "saxes/-/saxes-6.0.0.tgz"
                     "1nwn5r953v568imgl8zz9bkr1ra67zkbilk5qdsx3jqwpvxm5pqw")
        (npm-tarball "scheduler/-/scheduler-0.27.0.tgz"
                     "15ahpkgc65b3mal36m3szvlmhcz1rysbpifgg15z0cj0rqsww9mb")
        (npm-tarball "siginfo/-/siginfo-2.0.0.tgz"
                     "06vhqyr028bznlnfi0f4inr0526mk10ns5ya9ab4jh2iqi9xh3x2")
        (npm-tarball "slash/-/slash-3.0.0.tgz"
                     "01sxm2s0cvya4m52cb8w578a345nas5gwaw6dz7i2i9k9g8ig6pj")
        (npm-tarball "source-map-js/-/source-map-js-1.2.1.tgz"
                     "0ls8kncpxm2wxd4da6b1jrx1hyajjlx8rjyq34ra91x4zkwsc9pi")
        (npm-tarball "stack-utils/-/stack-utils-2.0.6.tgz"
                     "1zrf548x1j12fk93q95iqx1hmpvc87l09n3jsjaa03iqmd8shcpb")
        (npm-tarball "stackback/-/stackback-0.0.2.tgz"
                     "0n2qll6342m6219skx7cjmc6rpd747n4idj6sj779yfcs613qriy")
        (npm-tarball "std-env/-/std-env-4.1.0.tgz"
                     "1fn70gcvblwc49hgggfgadq1s5lg5wb4gbpc0r0p3x7wws9xvhpd")
        (npm-tarball "strip-indent/-/strip-indent-3.0.0.tgz"
                     "0zr4gkp894dr2gaq6jm6myrpgxcb254j0bidia2kajb6p42p55g5")
        (npm-tarball "supports-color/-/supports-color-7.2.0.tgz"
                     "0jjyglzdzscmhgidn43zc218q5jf9h03hmaaq9h4wqil2vywlspi")
        (npm-tarball "symbol-tree/-/symbol-tree-3.2.4.tgz"
                     "1g2ap5vvjzp141idqnd5vpn3hzy3ihwr8vqivyxdn2yh00570sca")
        (npm-tarball "tailwindcss/-/tailwindcss-4.2.4.tgz"
                     "1s242g2021b0aw5mm6zj35dmmlimc0q5hm2if7sp3d50fysv0qys")
        (npm-tarball "tapable/-/tapable-2.3.3.tgz"
                     "1kcj2yyxxqfy5784s8vq5s3d6313s8sqaqnfi36hx0lrha6w8mss")
        (npm-tarball "tinybench/-/tinybench-2.9.0.tgz"
                     "0f9fb0840qfhz6kbwpv12an1ia6qwbx7w7ml1xkmjqrnq99yjf1s")
        (npm-tarball "tinyexec/-/tinyexec-1.1.1.tgz"
                     "11kkin05z28f93mmi3ix3jd672mmr3kjgb2f1by13hv24gv9jm12")
        (npm-tarball "tinyglobby/-/tinyglobby-0.2.16.tgz"
                     "010lkihfjgsqy47vglzsv7prkwwlmbxhg4sin216wwg85pny1mg7")
        (npm-tarball "tinyrainbow/-/tinyrainbow-3.1.0.tgz"
                     "0hlq2h2knalxmfiapqv6c3nzpk7w7s9pmar114xfw9zwfzly8ww3")
        (npm-tarball "tldts-core/-/tldts-core-7.0.29.tgz"
                     "1i23ihj1l5i7kfqj0clqjfw9k1970csv9zr87ld010nmjazrmg4f")
        (npm-tarball "tldts/-/tldts-7.0.29.tgz"
                     "0jdv9gffrgpjk560i8if0hvbbhmkgd483gln56ci2hqnxhvixgzx")
        (npm-tarball "tough-cookie/-/tough-cookie-6.0.1.tgz"
                     "1xnqvj9qa06lsi7m27km85hbs8pwriax4rah3yzl08n7hvyw2lrd")
        (npm-tarball "tr46/-/tr46-6.0.0.tgz"
                     "10981qlbfz2n2ajgkz301dhwg7jk1650n2bppykl08g975k18dw7")
        (npm-tarball "tslib/-/tslib-2.8.1.tgz"
                     "17hiw9pawyczkhsnhlq4k9dn3kq2l49nk5rlfn049bmbxvakbxk6")
        (npm-tarball "typescript/-/typescript-6.0.3.tgz"
                     "0anjcm0xk05wkls2sz1dlhs4rsnxc9n87nm92nfrx35apvhhxk9k")
        (npm-tarball "undici-types/-/undici-types-7.19.2.tgz"
                     "1s3pnsm3kn96lfhs6qk1z45r6bgp78r4qmd7f3fycr8ncps75kaa")
        (npm-tarball "undici/-/undici-7.25.0.tgz"
                     "1y5cmx731159y08klf4z1mbrscj7g3fr2dsls4rndhmlifkykgf9")
        (npm-tarball "update-browserslist-db/-/update-browserslist-db-1.2.3.tgz"
                     "1hs4d1y9z7wa44z7kppyid1rzg2ysi54wfs6s3slssimsh0dmbvb")
        (npm-tarball "vite/-/vite-8.0.10.tgz"
                     "0mhvng281ddxp4bn9cz6yvwm6dkiy1fdg4z41xs6f6x9dg8lnd85")
        (npm-tarball "vitest/-/vitest-4.1.5.tgz"
                     "17ygqg50shmm5acgd7i8avbsm24fadcvrpwl65lasxzs7imgbzx6")
        (npm-tarball "w3c-xmlserializer/-/w3c-xmlserializer-5.0.0.tgz"
                     "00xxzsz5qd800zj1g18xah2dnnylmamcg93pwqr8j8l2pcrhrskz")
        (npm-tarball "webidl-conversions/-/webidl-conversions-8.0.1.tgz"
                     "1sdrrg654nxbccsnrdpsajs5ad2ngpxc9vhxs5k203ry0v10js01")
        (npm-tarball "whatwg-mimetype/-/whatwg-mimetype-5.0.0.tgz"
                     "1n5f6wy7c1fniwdvg2krmma7ayq33jvrwwbjhgrvy8kvxpbfy71q")
        (npm-tarball "whatwg-url/-/whatwg-url-16.0.1.tgz"
                     "0cgwspap3nq1va6scb7cfv9q7gxqb1ycmnhxdg8i5sl78w24h18p")
        (npm-tarball "why-is-node-running/-/why-is-node-running-2.3.0.tgz"
                     "0qwrxh3bl4mdf9cb1y4ls57gddgmr5x621ggg409sl2kg7vnixnj")
        (npm-tarball "xml-name-validator/-/xml-name-validator-5.0.0.tgz"
                     "1gph2grgwmw7xi1mzaaj4qd10wpvmaml61d2iqraccmfim1b2h1x")
        (npm-tarball "xmlchars/-/xmlchars-2.2.0.tgz"
                     "1a3daxxjcy0p0qbxcqp6d9z6h1czsab5xabanyavvr33i4lh1ydx")))

(define faforever-client-npm-tarballs
  (list (npm-tarball "@babel/code-frame/-/code-frame-7.29.7.tgz"
                     "0rwwq509ywaizggi0l54awqr6xag3wzl8cxd84mxgldml1pig2zs")
        (npm-tarball "@babel/compat-data/-/compat-data-7.29.7.tgz"
                     "1fal7mxcp45nvfwad5f7fa43zsxjhdc07gklfpf4nr84sxg3pxhc")
        (npm-tarball "@babel/core/-/core-7.29.7.tgz"
                     "1lqfi8f86sxma5naq9rz06l49dcs74xz20cy1sm9vhib7n5lbpa6")
        (npm-tarball "@babel/generator/-/generator-7.29.8.tgz"
                     "0bah3g97rcis8h7jfrjycawk31rsq11nqrw2j5a81993gkyx9kmm")
        (npm-tarball "@babel/helper-compilation-targets/-/helper-compilation-targets-7.29.7.tgz"
                     "1q1lp5mdx9jm23kigf6pmkdcvbvnbvvgb2ihrcwbl41bsgrlcm2v")
        (npm-tarball "@babel/helper-globals/-/helper-globals-7.29.7.tgz"
                     "0grabnbgzmyl9lqh7iypvmnwfg88453lkwc1am72rbls90n9dywl")
        (npm-tarball "@babel/helper-module-imports/-/helper-module-imports-7.29.7.tgz"
                     "033prrn6sv3zipf15hd31g19ckx3kham3wbhczhmr1vvb77ldpsb")
        (npm-tarball "@babel/helper-module-transforms/-/helper-module-transforms-7.29.7.tgz"
                     "1r768nx6lllw0salkmbb9i3518dihmv339jqmzsjha0a1fqvkcyv")
        (npm-tarball "@babel/helper-string-parser/-/helper-string-parser-7.29.7.tgz"
                     "09yizqbgb57pdbyxv284bzjrdwn4s6qsc2q6fdwiimq0sgn6ai8j")
        (npm-tarball "@babel/helper-validator-identifier/-/helper-validator-identifier-7.29.7.tgz"
                     "07ywjzwh0xw22zazdw2bzckllvr929ypkpg5slrb46szqi5r0cbs")
        (npm-tarball "@babel/helper-validator-option/-/helper-validator-option-7.29.7.tgz"
                     "1kg44680yhgy52rxf5zfhcdxdqdn5i6q9w4j1whwam84rkr8ybg3")
        (npm-tarball "@babel/helpers/-/helpers-7.29.7.tgz"
                     "1ij2grdm74j2ixpmb096rhb2cw931j0ryb45vqjh4bcg5qvxip47")
        (npm-tarball "@babel/parser/-/parser-7.29.8.tgz"
                     "101wj3pwqv1s2nkrhbz25z3q88jyzxcyws7c1mfscsq64fdlbw90")
        (npm-tarball "@babel/runtime/-/runtime-7.29.7.tgz"
                     "19csnq2xy2ny8kr03vfjcq35z1l46b8kiiswc93lv9m10bainzsd")
        (npm-tarball "@babel/template/-/template-7.29.7.tgz"
                     "0r3p1rd4jswaqz368akc2gci0j5qdw4hznpjbz7qds9nan6y43jy")
        (npm-tarball "@babel/traverse/-/traverse-7.29.8.tgz"
                     "0d72hgzmv3rdfrfbap7hb470wcmnc9a5vn543cv6dmvg6lgqc5ng")
        (npm-tarball "@babel/types/-/types-7.29.8.tgz"
                     "1pk9h0lyg8smbg96jh2snwp5wx0qynjwb29yy0bi9zjmjg84wjji")
        (npm-tarball "@eslint-community/eslint-utils/-/eslint-utils-4.10.1.tgz"
                     "1z71j02hv09znlkmh76fsrryrgxrl9a2dgwwwwhkl7yjp0y1bgr3")
        (npm-tarball "@eslint-community/regexpp/-/regexpp-4.12.2.tgz"
                     "04hgmvpsk3810z2zni47wkrr8ncr21wsaykbx48zaixd0kk25jxm")
        (npm-tarball "@eslint/config-array/-/config-array-0.23.5.tgz"
                     "1y6hll9gj5v6jqx7h6rc5v9l9y5lx4pqck3yrmlvdfddmk7y2jp9")
        (npm-tarball "@eslint/config-helpers/-/config-helpers-0.7.0.tgz"
                     "1jhpkz5bc5vaqlcn4896s76kr5pnar93x7p21l4j6da6x6962654")
        (npm-tarball "@eslint/core/-/core-1.2.1.tgz"
                     "1rhgyacvwv24vxz28nb38ccyqil92fk59pfv0y573b11d9b8l9vp")
        (npm-tarball "@eslint/js/-/js-10.0.1.tgz"
                     "1qnf9mh2xv1saqsrdpl2fw2yasimb0yz81z0ps8q474vx4p3bkcf")
        (npm-tarball "@eslint/object-schema/-/object-schema-3.0.5.tgz"
                     "1n956ydakf265c5k16xffw35ljm8wlkkphm1xdmkyy9lnnpw3j9d")
        (npm-tarball "@eslint/plugin-kit/-/plugin-kit-0.7.2.tgz"
                     "1fvcvlcapm357g8hmhn8y840lmihshjig1kwwqfhv24cyxa2kcjh")
        (npm-tarball "@humanfs/core/-/core-0.19.2.tgz"
                     "1bmfijmn9q6f816ycc54490p7gds14py5sxg8pxn93pbyxm4g1sd")
        (npm-tarball "@humanfs/node/-/node-0.16.8.tgz"
                     "1dn680jy50hn6jcvcbxcqm643628wa4kx5srymf0vf3w7p0vggmp")
        (npm-tarball "@humanfs/types/-/types-0.15.0.tgz"
                     "1mcl190chb8dln59s4h34i8awvp7xsn5yni54yxgc8d3ggd44a9w")
        (npm-tarball "@humanwhocodes/module-importer/-/module-importer-1.0.1.tgz"
                     "06hg3l6kmjml65ks9d4g3x83xndi50vnkngrgav0zibnr4qdy5k9")
        (npm-tarball "@humanwhocodes/retry/-/retry-0.4.3.tgz"
                     "1012l1avlfw5zcrljg6cwmy0gcb1mdqz0l6m09aixa8kh3gasx3p")
        (npm-tarball "@jridgewell/gen-mapping/-/gen-mapping-0.3.13.tgz"
                     "10h05zv5qcbxiz5wslzqv1aik7zl0cfqiarqhw63xmpnq5cgc5mw")
        (npm-tarball "@jridgewell/remapping/-/remapping-2.3.5.tgz"
                     "00hssw2k05fxp4fgjk9182bgynx2b4slfcvwwir6dlcslf16gcbh")
        (npm-tarball "@jridgewell/resolve-uri/-/resolve-uri-3.1.2.tgz"
                     "0c72fqvljvr28rdmg6hjd8zc63vm00r9xlrx6l9spfjq4pvgjlnv")
        (npm-tarball "@jridgewell/sourcemap-codec/-/sourcemap-codec-1.5.5.tgz"
                     "11b5h4hihb2n8203znalqm53s7pv82a84jahsqgf7rd2406kpba7")
        (npm-tarball "@jridgewell/trace-mapping/-/trace-mapping-0.3.31.tgz"
                     "1krw8nqmca9k4gb20kh9mpfsjb2b6ggrx226haz5l3b336hp2k66")
        (npm-tarball "@oxc-project/types/-/types-0.155.0.tgz"
                     "0ls8qk073s4xcmy89zc17x2x8a689khkn2chdxzczzp59q68rhzx")
        (npm-tarball "@rolldown/binding-linux-x64-gnu/-/binding-linux-x64-gnu-1.2.15.tgz"
                     "1hd3mj5cdg20qm1l3nqfc6wf85b0m4xb9c8bnglwbmrbwy9vcgf1")
        (npm-tarball "@rolldown/binding-linux-x64-musl/-/binding-linux-x64-musl-1.2.15.tgz"
                     "1jy274fcga4nbr7jppys2q1mrjix83n9lwgm408ail7wvmmy65rw")
        (npm-tarball "@rolldown/pluginutils/-/pluginutils-1.0.1.tgz"
                     "001ldr3l4winhwh98kmy28jg497xc95jw5qwhs75my9p7m1b7z0k")
        (npm-tarball "@standard-schema/spec/-/spec-1.1.0.tgz"
                     "1byfgh3b6ngdj4vba2jw48bk9wl6gjqc7y2hshcba2i8prl75jx7")
        (npm-tarball "@tauri-apps/api/-/api-2.11.0.tgz"
                     "0b7498y6ggf66v0glqxzc4a6rjcc1xd3c54sdbn1ki6y6kxc6n9y")
        (npm-tarball "@tauri-apps/cli-linux-x64-gnu/-/cli-linux-x64-gnu-2.11.2.tgz"
                     "066rhky13c5g39xkdncl3cxwr3rc4pmpk0j9dvbbdx1lizgzsph7")
        (npm-tarball "@tauri-apps/cli-linux-x64-musl/-/cli-linux-x64-musl-2.11.2.tgz"
                     "11ckj3rfc8a2l2d4vzvqqdrpf1gzbq3iixv6ja21srv6b35z10l9")
        (npm-tarball "@tauri-apps/cli/-/cli-2.11.2.tgz"
                     "1irngh8cq5wdnlhila82c4cqcc56vap0sq7p4xcs57pwh9j3q9sk")
        (npm-tarball "@tauri-apps/plugin-notification/-/plugin-notification-2.3.3.tgz"
                     "14wp32gj7msnb0zqw36ijaxlvnhag10ddiqlhvka08hq8xfyskcl")
        (npm-tarball "@tauri-apps/plugin-opener/-/plugin-opener-2.5.4.tgz"
                     "1lpxq5j55jxldx0ifg0fvip2ww24b4whj9x87jw2gjgfymddwxwp")
        (npm-tarball "@testing-library/dom/-/dom-10.4.2.tgz"
                     "0m4wdmq0yf1w8gbv84qkmxyz80qr11sqidgld1kv6nn4d1ddhiba")
        (npm-tarball "@testing-library/react/-/react-16.3.3.tgz"
                     "0kla630lzcrcm0lg3qm0910n7m50m0a1p9sm4r4z8pzpgymr6jd3")
        (npm-tarball "@testing-library/user-event/-/user-event-14.6.7.tgz"
                     "0yjm1df5wh9w16y3yc3vlb8l33gsrsjyl5mljj6rrhm3xhj4ki4x")
        (npm-tarball "@types/aria-query/-/aria-query-5.0.4.tgz"
                     "1j569fqjjymh1zbixnyba6qibx5s10dj6bwxywlfa0sjxx5p0m6l")
        (npm-tarball "@types/chai/-/chai-5.2.3.tgz"
                     "153zvpnbwgi62h75w9jzcjpayr87af2rnvidk8npvq9q8bim432z")
        (npm-tarball "@types/deep-eql/-/deep-eql-4.0.2.tgz"
                     "01rnbz1kbwyrs8bh1ljzqajcbx1d6h82pcb2d6yj68ndy9gihgdn")
        (npm-tarball "@types/esrecurse/-/esrecurse-4.3.1.tgz"
                     "1gx1bb3lvdlxzp3wdyvr6iv0czc87l5kshjkwmbs2rpx2mjqqcyc")
        (npm-tarball "@types/estree/-/estree-1.0.9.tgz"
                     "0n5k5ff2mvz30d6ymcipng9ii6vgryk4a328lfspsj91zc6kr3zc")
        (npm-tarball "@types/json-schema/-/json-schema-7.0.15.tgz"
                     "092pv4k6dfr3wdsj78inq4iwygx53daj1hizcvqbz6bhzzfb3p0j")
        (npm-tarball "@types/node/-/node-26.6.4.tgz"
                     "004p2kjwi4kcprypa902c7b7zrzw18alspjdzj0ldlycrw8vybdz")
        (npm-tarball "@types/prop-types/-/prop-types-15.7.15.tgz"
                     "0qizyiz5q479nxp2xdnb8hivy40cjwwzwa0w2qy1vz0klfapi4ba")
        (npm-tarball "@types/react-dom/-/react-dom-18.3.7.tgz"
                     "1956g28n3vrmvcm1nyhxhsvfal6j9w75cp9ccnwh5am3zapb8n3d")
        (npm-tarball "@types/react/-/react-18.3.31.tgz"
                     "189wqbffkl6vy9bipd1pyb3xkfk3jy3wl9z05nk7702rpbsxsh63")
        (npm-tarball "@types/whatwg-mimetype/-/whatwg-mimetype-3.0.2.tgz"
                     "1lzk8vx59qf9fvdwwh76p19i1alhkgg2kwf0n1zzgny2sf72n8fv")
        (npm-tarball "@types/ws/-/ws-8.18.2.tgz"
                     "1zl3vgw2jxx2zvs7q25iyx7gh3ygd65zccbvlj6zb5skvq246xwx")
        (npm-tarball "@typescript-eslint/eslint-plugin/-/eslint-plugin-8.66.0.tgz"
                     "0pmhdxgbwbi9ifhnij1b8hb01xzh404ski9n6aqav5hjs6554k05")
        (npm-tarball "@typescript-eslint/parser/-/parser-8.66.0.tgz"
                     "0mal84wzqwzvm5058ziyk54v93zd63wddicw84mqlmyy92fn7839")
        (npm-tarball "@typescript-eslint/project-service/-/project-service-8.66.0.tgz"
                     "1h68visac9gcdx4z0wfw1m8in1771yym50wf4i277mscd968nn2h")
        (npm-tarball "@typescript-eslint/scope-manager/-/scope-manager-8.66.0.tgz"
                     "1m70xf619ywx2yjhscr9gq8riaq9wislbclxayrs4wf11y4ffz30")
        (npm-tarball "@typescript-eslint/tsconfig-utils/-/tsconfig-utils-8.66.0.tgz"
                     "1dkc0bzrn3z4b824bs99pyl6zfglvy97r3ibikqllqash5wzgpl9")
        (npm-tarball "@typescript-eslint/type-utils/-/type-utils-8.66.0.tgz"
                     "1krw6kc367wdgiaij677jqh6pjnajb0dwzhkbk4w2c0pfqmibwc1")
        (npm-tarball "@typescript-eslint/types/-/types-8.66.0.tgz"
                     "14s2rkd5bjcmd7126ayxs7jr3lhj3d9mf3c9vgb1xllm12ajms61")
        (npm-tarball "@typescript-eslint/typescript-estree/-/typescript-estree-8.66.0.tgz"
                     "1qm4mh63av9bvdhd2xvgaq4nl9f8qfzybb6bhqqafjgdg7bcsccx")
        (npm-tarball "@typescript-eslint/utils/-/utils-8.66.0.tgz"
                     "0hv8vc8jz6nphqigjagr4rxf0l1lc91ckisxp91ni27nj129smwb")
        (npm-tarball "@typescript-eslint/visitor-keys/-/visitor-keys-8.66.0.tgz"
                     "1f8zqdd5pidq1jrfgrxpy0fgvximr5ply6jal5bcsr712cd53fig")
        (npm-tarball "@vitejs/plugin-react/-/plugin-react-6.0.2.tgz"
                     "1f184dzm7sw1613jngr6qdzh1p44v8f473x74m4gdb62n3fi4ccq")
        (npm-tarball "@vitest/expect/-/expect-4.1.12.tgz"
                     "1dkv3xqgbwlspp23i6xv0dz8qg32cddlrd0j0fjdr47yv9j214wc")
        (npm-tarball "@vitest/mocker/-/mocker-4.1.12.tgz"
                     "0llwwjdhzmj1gw6yvgfd92kzwzl7p041c0wwcif9yci880ac16lg")
        (npm-tarball "@vitest/pretty-format/-/pretty-format-4.1.12.tgz"
                     "106xlli21l62z5g0l0l4jdkk2ck476c921szwmvfdngyva9yp6wj")
        (npm-tarball "@vitest/runner/-/runner-4.1.12.tgz"
                     "1kz6cvsrwcrf819ijh9lbgknihrigrdkrssc38g2jazbvibbj786")
        (npm-tarball "@vitest/snapshot/-/snapshot-4.1.12.tgz"
                     "1xfxpn64gwmj0x9ymhbcaacbs9mzajhj4knnklq11l9prfqpzd8h")
        (npm-tarball "@vitest/spy/-/spy-4.1.12.tgz"
                     "18s4z9sa81yq1ap3s096ryafk5yjwqga9wswzhxz70hh1mr6g6pb")
        (npm-tarball "@vitest/utils/-/utils-4.1.12.tgz"
                     "0z9lvdbivblsjmq32iv6dh8w82x93h8pfq9693x55jxgsirg098c")
        (npm-tarball "acorn-jsx/-/acorn-jsx-5.3.2.tgz"
                     "1k2qj4av0nmrqa5xcn0hrjv9r5kv8x83238fsxb6lff581gb0ryr")
        (npm-tarball "acorn/-/acorn-8.18.0.tgz"
                     "0jp9gf56mvkqdzwn2p8ygrnyyp9673yv8ydq7rpvpicvizrc1m0a")
        (npm-tarball "ajv/-/ajv-6.15.0.tgz"
                     "02pd70mbvrv334m669pikx2y453i5ybzhnqx3n7ldvjxi6nr48gm")
        (npm-tarball "ansi-regex/-/ansi-regex-5.0.1.tgz"
                     "1ng0r2k4mcz7b2bfr6g1dschnxm0vifaslsvv2smv06smb6ss3hf")
        (npm-tarball "ansi-styles/-/ansi-styles-5.2.0.tgz"
                     "0px0skwhaf4yiwahjba34cr6c5am3b21paab5hnbny8j89h97pad")
        (npm-tarball "aria-query/-/aria-query-5.3.0.tgz"
                     "14jw4f6mbcz16yxbxypvm5133vlz0qkjvcxwvqp41a3819rnsc6a")
        (npm-tarball "assertion-error/-/assertion-error-2.0.1.tgz"
                     "0mhgq8w0jyw6x02gzy3p5zzfaglkly2lv38q4cqlz3mkr6rsbx3k")
        (npm-tarball "balanced-match/-/balanced-match-4.0.4.tgz"
                     "05pva90symmxg31miw4msmd9g0q1aspf7764pcqybvi5j66m09ch")
        (npm-tarball "baseline-browser-mapping/-/baseline-browser-mapping-2.11.12.tgz"
                     "1cnzgmc181kl6yc95nha8l99wp65slv4807v87zckmmfckr8b109")
        (npm-tarball "brace-expansion/-/brace-expansion-5.0.12.tgz"
                     "1d781fg6r753yllk9sjb81k4rcsskgrh2vgs0hpnj2zjg3n4i17g")
        (npm-tarball "browserslist/-/browserslist-4.28.7.tgz"
                     "15q9mdqqhcpsk8734b31giry50cgdzmq56mj2j183zb8wxvgbnk6")
        (npm-tarball "buffer-image-size/-/buffer-image-size-0.6.4.tgz"
                     "0bjapdm0hf75zw360kpx5bwci3y17r9ing37j0hdxkm246wgqg7p")
        (npm-tarball "caniuse-lite/-/caniuse-lite-1.0.30001809.tgz"
                     "0k9n52apbfkj9aj68xzig12in9fwj8zv7cb7ny8fyzzx7zqr7aii")
        (npm-tarball "chai/-/chai-6.2.2.tgz"
                     "0n2v0njbnmqdxvwzfb55fg6lbd5ybbsm4sz9k1hwaiak6xsdab3h")
        (npm-tarball "convert-source-map/-/convert-source-map-2.0.0.tgz"
                     "160qzrwfhj8xkc2ya476hp7sahaj5gnzv4hi6xl9zq74qwz2bxqp")
        (npm-tarball "cross-spawn/-/cross-spawn-7.0.6.tgz"
                     "1siqxlydjwpihy7klgd15cah56vsmxrdm3q90gndyfj1vh63530q")
        (npm-tarball "csstype/-/csstype-3.2.3.tgz"
                     "18r7fhq1k5apllflcqljwmkh8b0n649c28nbzrl7agy7w671yl7k")
        (npm-tarball "debug/-/debug-4.4.3.tgz"
                     "19z48fpic8jbb2833gh3bviylzp9512i2dsqhxd91s3fjjfarhc9")
        (npm-tarball "deep-is/-/deep-is-0.1.4.tgz"
                     "0g5z206z33f41cdh220vf7kpj61cfcnmlnrcrk1ffs5zqs1sl0qc")
        (npm-tarball "dequal/-/dequal-2.0.3.tgz"
                     "0dawdan67ns9pdm629n8mh9zmy7qdn65v86j21yicy4qcbb907cl")
        (npm-tarball "detect-libc/-/detect-libc-2.1.2.tgz"
                     "09wlldyqvhf2w7q4xcch4xh6pvldy7c2vbx83m48dzvcq07yq397")
        (npm-tarball "dom-accessibility-api/-/dom-accessibility-api-0.5.16.tgz"
                     "0a5qbgx92nzi8salzwx917sw0jbcp9fzgca3khm4c453qdvphrnf")
        (npm-tarball "electron-to-chromium/-/electron-to-chromium-1.5.402.tgz"
                     "0x9gfjx72z1id7asgd12k8j2lawrn70swk9nf369146k306bkdj9")
        (npm-tarball "entities/-/entities-7.0.1.tgz"
                     "1843sjzia0074bh93aighhlnhz6p8bx12h3i742dm7psg4m7wjsm")
        (npm-tarball "es-module-lexer/-/es-module-lexer-2.3.1.tgz"
                     "1ba8fmkfx7i0zrznmrfdaqg427zc77ad8y9fzy8faksdxv20x4w2")
        (npm-tarball "escalade/-/escalade-3.2.0.tgz"
                     "1rxy0388xsgxam8limnbxhksa1z1xccd47vi4r9p1ip6q2pma9xs")
        (npm-tarball "escape-string-regexp/-/escape-string-regexp-4.0.0.tgz"
                     "06xi6f77ybg7cl673bawycpp6984h2ridzy2hl2kqylqlr6s2i2b")
        (npm-tarball "eslint-plugin-react-hooks/-/eslint-plugin-react-hooks-7.1.1.tgz"
                     "0lyzhpyv5q0gbyx595d3s3ql3462kf3p2f9891y8f5pjz38fr4pv")
        (npm-tarball "eslint-scope/-/eslint-scope-9.1.2.tgz"
                     "1hsx36rr3cfx5djv6p8sg2fkas62aga22j64jrmlqqsnw3209c0n")
        (npm-tarball "eslint-visitor-keys/-/eslint-visitor-keys-3.4.3.tgz"
                     "1sma85l113d6wmbi0v1iayg0h91zsd2karf5zx0y2ihfc4n5kkih")
        (npm-tarball "eslint-visitor-keys/-/eslint-visitor-keys-5.0.1.tgz"
                     "13bjnvhfbyd37zs1kzq5v347mjh40zf3rc04gym77k731wlla2fc")
        (npm-tarball "eslint/-/eslint-10.8.1.tgz"
                     "0mpf2w6n9p2rzkc5d82dvp198dxvln23vzx6f30ahg5y5zfqmj0z")
        (npm-tarball "espree/-/espree-11.2.0.tgz"
                     "1zcipyc0aqpzlx72g9bks9jxs1vmjkq8axr1ygply9sykrzrk70l")
        (npm-tarball "esquery/-/esquery-1.7.0.tgz"
                     "19bspabl1sxj79kx2c5rf05ki6jkm7j7s6apjw7vr0zigqg6l4qr")
        (npm-tarball "esrecurse/-/esrecurse-4.3.0.tgz"
                     "0q9vg6dmzdcy4mmm6dnmz1d9dfrm1gvi32n8f2slfsr9sxq97kry")
        (npm-tarball "estraverse/-/estraverse-5.3.0.tgz"
                     "19pxf86qwp2xl1i8k5w6q81aaldmspmgys0ksnla91c0bgd4b39y")
        (npm-tarball "estree-walker/-/estree-walker-3.0.3.tgz"
                     "1cvj3jfzlrg1dskkcwbjaccc00s16jma8mag8yg0kvyrdk0zvgdv")
        (npm-tarball "esutils/-/esutils-2.0.3.tgz"
                     "03v4y32k50mbxwv70prr7ghwg59vd5gyxsdsbdikqnj919rvvbf5")
        (npm-tarball "expect-type/-/expect-type-1.4.0.tgz"
                     "18g3a3hbhxbrh54s1dmy7iavzpp8f6hpsicb6b7a9s6aggm3yjy4")
        (npm-tarball "fast-deep-equal/-/fast-deep-equal-3.1.3.tgz"
                     "13vvwib6za4zh7054n3fg86y127ig3jb0djqz31qsqr71yca06dh")
        (npm-tarball "fast-json-stable-stringify/-/fast-json-stable-stringify-2.1.0.tgz"
                     "11qnzlan5yd2hg9nqi9hdv48bq6kwvw9pxsxir22n2iyqhighb8y")
        (npm-tarball "fast-levenshtein/-/fast-levenshtein-2.0.6.tgz"
                     "0g5zgdlp38dli94qbbm8vhvmj90fh48sxpggfn2083wbdcq50jxv")
        (npm-tarball "fdir/-/fdir-6.5.0.tgz"
                     "0pin1ngw51v3z7q8gs4q84bwwcw3pdyh29jk8351yahyygcxq794")
        (npm-tarball "file-entry-cache/-/file-entry-cache-8.0.0.tgz"
                     "1f2p5nmcw95z754r3msds3z39rhgsqxcldc93x512s12x9n5mb37")
        (npm-tarball "find-up/-/find-up-5.0.0.tgz"
                     "1d3mr9ifkyz3dljjm6gr6av87a3s7zyn66fq72bc0s9pb3xlx9pl")
        (npm-tarball "flat-cache/-/flat-cache-4.0.1.tgz"
                     "1w6smvr0qqdyvsvn2ws5m3ykrsb795mjy47llh92hyc4n3i5l272")
        (npm-tarball "flatted/-/flatted-3.4.4.tgz"
                     "0mgs5svl621fgvvga03ckdivxsjb3vigdqcadr4r6l9nkl95bp2x")
        (npm-tarball "gensync/-/gensync-1.0.0-beta.2.tgz"
                     "1j8piprq5pvns7j60gm0jkrdmnm8zrfl2wwarf94ypd34vpr57yz")
        (npm-tarball "glob-parent/-/glob-parent-6.0.2.tgz"
                     "0rjhim72pkv230y79xdahhpcnhy4y8fxr7dhr8sf47xyyd1bjnrl")
        (npm-tarball "globals/-/globals-17.9.0.tgz"
                     "1ig5q4cgg2crp5vrabcncgkrq5dfj06m2rhldkvha7d9ssyavk1h")
        (npm-tarball "happy-dom/-/happy-dom-20.14.5.tgz"
                     "0jzkg6392cjiyjjvxhqlm4g7js5cgv359lnbpkbvzkayxh4wf68n")
        (npm-tarball "hermes-estree/-/hermes-estree-0.25.1.tgz"
                     "1k7pw8xw03qlhgg0flb5kan52z59i6aalmg3fn9vahzp87dskc29")
        (npm-tarball "hermes-parser/-/hermes-parser-0.25.1.tgz"
                     "1aiwlhc5a0sr4lpy3gffiygg6x46160ljs2kc89jkpci1wnqh2bl")
        (npm-tarball "ignore/-/ignore-5.3.2.tgz"
                     "1gfqxqkxck02zkdy2026fkskkrlqv476a4cfqzg3djjzbwh555lf")
        (npm-tarball "ignore/-/ignore-7.0.6.tgz"
                     "0s3xqrc9ppi0h4b9qmy17dhzj2qj4zcvssv01swrqi0qyvfsqzy4")
        (npm-tarball "imurmurhash/-/imurmurhash-0.1.4.tgz"
                     "0q6bf91h2g5dhvcdss74sjvp5irimd97hp73jb8p2wvajqqs08xc")
        (npm-tarball "is-extglob/-/is-extglob-2.1.1.tgz"
                     "06dwa2xzjx6az40wlvwj11vican2w46710b9170jzmka2j344pcc")
        (npm-tarball "is-glob/-/is-glob-4.0.3.tgz"
                     "1imyq6pjl716cjc1ypmmnn0574rh28av3pq50mpqzd9v37xm7r1z")
        (npm-tarball "isexe/-/isexe-2.0.0.tgz"
                     "0nc3rcqjgyb9yyqajwlzzhfcqmsb682z7zinnx9qrql8w1rfiks7")
        (npm-tarball "js-tokens/-/js-tokens-4.0.0.tgz"
                     "0lrw3qvcfmxrwwi7p7ng4r17yw32ki7jpnbj2a65ddddv2icg16q")
        (npm-tarball "jsesc/-/jsesc-3.1.0.tgz"
                     "029w1pc3jck2y6bg2g9vvz3mij38l992zb7jhfzp16narhjj4w8c")
        (npm-tarball "json-buffer/-/json-buffer-3.0.1.tgz"
                     "19gmzrfyy4k7sckqgc3gsz5hpkjg6gg75nhrr5rmyg3ip56ldxyi")
        (npm-tarball "json-schema-traverse/-/json-schema-traverse-0.4.1.tgz"
                     "0rf0pvm62k8g81vs7n7zx080p6sfylwk52vc149jx1216vcssdgp")
        (npm-tarball "json-stable-stringify-without-jsonify/-/json-stable-stringify-without-jsonify-1.0.1.tgz"
                     "1smffz68mhcb5w6ckflwfh2n91nbi6z0vk8rhbxvk3lbhnn61gax")
        (npm-tarball "json5/-/json5-2.2.3.tgz"
                     "0yrpsb1frqahc48n6w2jzvhd7m8r9w2w9ylqkg41zl80nqyv7bq8")
        (npm-tarball "keyv/-/keyv-4.5.4.tgz"
                     "1630gds0l00zmx2kiaa76ybf6ig7ygsm8ssy6sjg8yp5c72z29pb")
        (npm-tarball "levn/-/levn-0.4.1.tgz"
                     "1lb7409xvyj4sz36pslhrcz283yycc1fxzf0k4c554qgvza5fi0z")
        (npm-tarball "lightningcss-linux-x64-gnu/-/lightningcss-linux-x64-gnu-1.33.0.tgz"
                     "1lz1yg4453p2fqmmrs4fsnsskqfqgyl7z1nxckw4wb08azymsj7x")
        (npm-tarball "lightningcss-linux-x64-musl/-/lightningcss-linux-x64-musl-1.33.0.tgz"
                     "0ha4ca22gm9ydbvrgfsjgdxvqj6d9ywkb0230g7bag9r7h7s38gk")
        (npm-tarball "lightningcss/-/lightningcss-1.33.0.tgz"
                     "1kwqamrgl53w6sicddrxl8byl2718kwqwqy2lgm4q8xpickz94nl")
        (npm-tarball "locate-path/-/locate-path-6.0.0.tgz"
                     "0al3dmihydmwr89wc4ivqnkww7gm9p2ysq57j5qrj6sq8ckhplki")
        (npm-tarball "loose-envify/-/loose-envify-1.4.0.tgz"
                     "1p5b3ca0b2jkxalyg7h9bss6aspa8plkh0ak1mrlz2jkjc58660j")
        (npm-tarball "lru-cache/-/lru-cache-5.1.1.tgz"
                     "0nj8d71w5yb3rmiaxby5scwfl0n1jdaplr0p6dp619j4jn0ph7mi")
        (npm-tarball "lz-string/-/lz-string-1.5.0.tgz"
                     "06q1br6dbr8kby28p707pawlsczifhwx7vb6b81whjy5kzvhqr5d")
        (npm-tarball "magic-string/-/magic-string-0.30.21.tgz"
                     "0vv5mh4rnr83gnpd0kkspy1c810f4mfkczrjry64x96wcwjpcjgs")
        (npm-tarball "minimatch/-/minimatch-10.2.6.tgz"
                     "1y2m0dvd682xw3phaacnlxb1i54h2257pr17axk2k0m2fj02qgas")
        (npm-tarball "ms/-/ms-2.1.3.tgz"
                     "1ii24v83yrryzmj9p369qxmpr53337kkqbdaklpmbv9hwlanwqgn")
        (npm-tarball "nanoid/-/nanoid-3.3.20.tgz"
                     "0kywxr4fiim1dqbfxiw19qslq01w3yy63lwinq22qb52k9vk9qas")
        (npm-tarball "natural-compare/-/natural-compare-1.4.0.tgz"
                     "1vkrwxgc7w81923739lrnqklmpnin52qmhd868vgfr10s7n6jmay")
        (npm-tarball "node-releases/-/node-releases-2.0.53.tgz"
                     "16nq1si3c0yfnijn2wn1ysykgdqn5wqka5mdvx3x8d2n5gzj4lbj")
        (npm-tarball "obug/-/obug-2.1.4.tgz"
                     "0xakzd5dpa4q13iig17gb8n7bq5a0m6a69smkmslf3jis16qyqc7")
        (npm-tarball "optionator/-/optionator-0.9.4.tgz"
                     "0sw2q8l29b0a5gfa6zh6941qz5vfrm9h6lzpclg2rbxl87hvnwm7")
        (npm-tarball "p-limit/-/p-limit-3.1.0.tgz"
                     "1q69dflz7cr8j18l0va73jyg2nrzd0vq3jhvvica3yna6sbm3rin")
        (npm-tarball "p-locate/-/p-locate-5.0.0.tgz"
                     "1z136h1a3c6a20dzsi5qc24ajk2gs8r59gj1n59sfr89m6019h9f")
        (npm-tarball "path-exists/-/path-exists-4.0.0.tgz"
                     "0p3pzdvfy2il8p0dvpp1l688in68bh2zzqzcfzvv7s9c634kbdfv")
        (npm-tarball "path-key/-/path-key-3.1.1.tgz"
                     "14kvp849wnkg6f3dqgmcb73nnb5k6b3gxf65sgf0x0qlp6n9k2ab")
        (npm-tarball "pathe/-/pathe-2.0.3.tgz"
                     "0dnzjq3529b584wj6rich8p0c16s0ydlbn7miw88lzxvbny76fvf")
        (npm-tarball "picocolors/-/picocolors-1.1.1.tgz"
                     "1nc2z3w16wpz2840srcwyxd747khwfvh66yigyrpwywn0wldpbnk")
        (npm-tarball "picomatch/-/picomatch-4.0.4.tgz"
                     "072pg3ji6ib0ns6jv3ypink59pmfj8432fj82yhxk3jmcsv5lnsi")
        (npm-tarball "picomatch/-/picomatch-4.0.7.tgz"
                     "1a20wz4mq49bigbh7dszhyaxz7d6358gv521izy9zgfdwcxlcyv9")
        (npm-tarball "postcss/-/postcss-8.5.31.tgz"
                     "0611p8r5sv3wlp2mfyrypcg9hx55hh0fbxwyk30pnra7ls69jg0i")
        (npm-tarball "prelude-ls/-/prelude-ls-1.2.1.tgz"
                     "14fjp2mzgn4a705pkwggdy3dib854q0rvlmylpyjz18zgwwzrs0l")
        (npm-tarball "pretty-format/-/pretty-format-27.5.1.tgz"
                     "00s1ld3k7zxx8mxfq8zq49hbnf69z43ggyxjhgipc8f53p4y42zr")
        (npm-tarball "punycode/-/punycode-2.3.1.tgz"
                     "1fwkw4ir7gp3i845xv3bj4a4cswgcnmpjwmqpad38i5czgwmkkp4")
        (npm-tarball "react-dom/-/react-dom-18.3.1.tgz"
                     "1q20n02nai7cznb4h3yi8x7px9llhlqbzfqqmin3ybwzm4kl8783")
        (npm-tarball "react-is/-/react-is-17.0.2.tgz"
                     "1c9yjrjhipdynvkxq035qhd6b9q3l60i482ah6dqxh2gbg05064v")
        (npm-tarball "react/-/react-18.3.1.tgz"
                     "0iq3hz3mmzgrc1h3181hk8446skwshd7hbclhzrymrvjlq0yv6wd")
        (npm-tarball "rolldown/-/rolldown-1.2.15.tgz"
                     "0rshcaa6f58fv6jlpl1bnlfbsqqc2mmpbfgk0mvbhs7i6ygnhkhg")
        (npm-tarball "scheduler/-/scheduler-0.23.2.tgz"
                     "1bi6dzp0zb1w0plxa6vzpynjc4wwmz8hlay9cvpr7ax9cgzdiwg4")
        (npm-tarball "semver/-/semver-6.3.1.tgz"
                     "0c0jxgjhgpxx7hdbmwghndq2mdpg58295mwv1b8cp6g070m096rw")
        (npm-tarball "semver/-/semver-7.8.5.tgz"
                     "0pbx2afqpl5na8j25kgz496g6wrfaggrasrkj745fz8d63a4al6q")
        (npm-tarball "shebang-command/-/shebang-command-2.0.0.tgz"
                     "0vjmdpwcz23glkhlmxny8hc3x01zyr6hwf4qb3grq7m532ysbjws")
        (npm-tarball "shebang-regex/-/shebang-regex-3.0.0.tgz"
                     "13wmb23w5srjpn9xx1c85yk5jbc5z9ypg0iz33h6nv5jdnmapnzy")
        (npm-tarball "siginfo/-/siginfo-2.0.0.tgz"
                     "06vhqyr028bznlnfi0f4inr0526mk10ns5ya9ab4jh2iqi9xh3x2")
        (npm-tarball "source-map-js/-/source-map-js-1.2.2.tgz"
                     "18vi9pzfif85palsp4pwbri4n3xi8a9zws3nvb55csrsgj7czj05")
        (npm-tarball "stackback/-/stackback-0.0.2.tgz"
                     "0n2qll6342m6219skx7cjmc6rpd747n4idj6sj779yfcs613qriy")
        (npm-tarball "std-env/-/std-env-4.2.0.tgz"
                     "02m4wf40858j96qwfcp3d75kxzy0hrxmy34j75kaczcrgqlbrqnk")
        (npm-tarball "tinybench/-/tinybench-2.9.0.tgz"
                     "0f9fb0840qfhz6kbwpv12an1ia6qwbx7w7ml1xkmjqrnq99yjf1s")
        (npm-tarball "tinyexec/-/tinyexec-1.3.0.tgz"
                     "1m7kix3j7wfgsfh81h7kz6dwi1p6b103gv7n3mcsh3wnd8fah24b")
        (npm-tarball "tinyglobby/-/tinyglobby-0.2.17.tgz"
                     "0qmmih2r0i4379hrhd8cnjya15q9x8fd5q8kmirviy3mj6pazd5g")
        (npm-tarball "tinyrainbow/-/tinyrainbow-3.1.1.tgz"
                     "0i0pg6w2qnf2jaf99k5nfd559hg2zdy4s66xj2746ra6js0bkcfd")
        (npm-tarball "ts-api-utils/-/ts-api-utils-2.5.0.tgz"
                     "153rv09kbjy13m8nl924qv26wi16kahg9pnnjfjh6hdg0ab83l4z")
        (npm-tarball "type-check/-/type-check-0.4.0.tgz"
                     "13iza44xzxi2sfdz411wdfprl9wmlzgvlv60i8sr49lfqh6d2dc0")
        (npm-tarball "typescript-eslint/-/typescript-eslint-8.66.0.tgz"
                     "00m0rfyvhg33vf2cjn7gyb04s613z59yl8s898xivkqdcs53h99a")
        (npm-tarball "typescript/-/typescript-5.9.3.tgz"
                     "1lx1hwb5g73x06pylqzgrkran1dlbx8iizrx0mwjhpvxrz4hiq8h")
        (npm-tarball "undici-types/-/undici-types-8.9.0.tgz"
                     "1ikq7qx4grfa4k5pg93snwd2lzlxh7mki2mc1sr2245zri8phn1s")
        (npm-tarball "update-browserslist-db/-/update-browserslist-db-1.3.0.tgz"
                     "16473cmx6q1pwjavv47znxbf4cl5sia1vqmn8axpls4rxpdn6pi4")
        (npm-tarball "uri-js/-/uri-js-4.4.1.tgz"
                     "0bcdxkngap84iv7hpfa4r18i3a3allxfh6dmcqzafgg8mx9dw4jn")
        (npm-tarball "vite/-/vite-8.3.5.tgz"
                     "05vwvj83hqd0ys9w582gc19v93840qw42pswfnnwbfhminkw48kz")
        (npm-tarball "vitest/-/vitest-4.1.12.tgz"
                     "1l93r0kkhv7sxnibbv5v8l7gzl83pnf862lyq8fbrslr3ibcjydc")
        (npm-tarball "whatwg-mimetype/-/whatwg-mimetype-3.0.0.tgz"
                     "1sqpgdzrm8q02xi2i5mk1gr2zyy3znb2jhmyapxhsz090qprr890")
        (npm-tarball "which/-/which-2.0.2.tgz"
                     "1p2fkm4lr36s85gdjxmyr6wh86dizf0iwmffxmarcxpbvmgxyfm1")
        (npm-tarball "why-is-node-running/-/why-is-node-running-2.3.0.tgz"
                     "0qwrxh3bl4mdf9cb1y4ls57gddgmr5x621ggg409sl2kg7vnixnj")
        (npm-tarball "word-wrap/-/word-wrap-1.2.5.tgz"
                     "1v4xynx2nyawlbx0y6gpa52wqb5nns316bc2sc4slgw634xwrmyh")
        (npm-tarball "ws/-/ws-8.22.0.tgz"
                     "1j5bwyagz7a0vk0j61ikkfq15ah10ppm0gviqvxfh771nac3g6ya")
        (npm-tarball "yallist/-/yallist-3.1.1.tgz"
                     "016afm3iv7pfrg9nj7952dph6sg00lryk8wv4nr0qdp8rzk4mwah")
        (npm-tarball "yocto-queue/-/yocto-queue-0.1.0.tgz"
                     "1w99c4y6vl1q5dmw9hnkbiqxnmaz72x22qdc13mg084glpnbqwn7")
        (npm-tarball "zod-validation-error/-/zod-validation-error-4.0.2.tgz"
                     "1cly2a87g6ra8ms7scil24p7dj0ibyj7aflpmw0dk6dgp4islyya")
        (npm-tarball "zod/-/zod-4.4.3.tgz"
                     "17171zbchqs56621d99kxgs2cg215yp879450rhh1m9zadzz2f7f")
        (npm-tarball "zustand/-/zustand-5.0.14.tgz"
                     "0sz9as4v0h1dnpzxf0ab2vgkcq5xdb7axy2fdgsi57d74ghxkyn1")))

(define faforever-client-pnpm-tarball
  (cdr (npm-tarball "pnpm/-/pnpm-11.7.0.tgz"
                    "1vhmxqc340ak2rqvp59l5pic3593pqpvk2bj0im8n8d1k3nagbyy")))
