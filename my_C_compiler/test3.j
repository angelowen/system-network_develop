;.source
.class public static myResult
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
    ldc 2.0
    fstore 2
    fload 2
    ldc 2.0
    ldc 100.0
    ldc 1.0
    fsub
    fmul
    fadd
    fstore 3
getstatic java/lang/System/out Ljava/io/PrintStream;
fload_3
invokevirtual java/io/PrintStream/println(F)V
    ldc 25.34
    fstore 0
    ldc 331.0
    ldc 0.6
    fload 0
    fmul
    fadd
    fstore 1
getstatic java/lang/System/out Ljava/io/PrintStream;
fload_1
invokevirtual java/io/PrintStream/println(F)V
    return
.end method
