;.source
.class public static myResult
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
    bipush 5
    newarray int
    astore 6
    ldc 6
aload 6
bipush 4
bipush 2
iastore
getstatic java/lang/System/out Ljava/io/PrintStream;
ldc "hello"
invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
    return
.end method
