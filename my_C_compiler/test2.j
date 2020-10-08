;.source
.class public static myResult
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
    ldc 5.0
    fstore 0
    fload 0
    ldc 2.0
    fcmpl
    ifle ELSE
    ldc 10.123
    fstore 1
    goto END
ELSE:
    fload 0
    fstore 1
END:
getstatic java/lang/System/out Ljava/io/PrintStream;
fload_1
invokevirtual java/io/PrintStream/println(F)V
    ldc 21
    istore 3
    iload 3
    ldc 4
    iadd
    istore 2
getstatic java/lang/System/out Ljava/io/PrintStream;
iload_2
invokevirtual java/io/PrintStream/println(I)V
    return
.end method
