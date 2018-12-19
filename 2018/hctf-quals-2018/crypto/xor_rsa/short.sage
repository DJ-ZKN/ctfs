# coppersmiths_short_pad_attack.sage

def short_pad_attack(c1, c2, e, n):
    PRxy.<x,y> = PolynomialRing(Zmod(n))
    PRx.<xn> = PolynomialRing(Zmod(n))
    PRZZ.<xz,yz> = PolynomialRing(Zmod(n))

    g1 = x^e - c1
    g2 = (x+y)^e - c2

    q1 = g1.change_ring(PRZZ)
    q2 = g2.change_ring(PRZZ)

    h = q2.resultant(q1)
    h = h.univariate_polynomial()
    h = h.change_ring(PRx).subs(y=xn)
    h = h.monic()

    kbits = n.nbits()//(2*e*e)
    diff = h.small_roots(X=2^kbits, beta=0.5)[0]  # find root < 2^kbits with factor >= n^0.5

    return diff

def related_message_attack(c1, c2, diff, e, n):
    PRx.<x> = PolynomialRing(Zmod(n))
    g1 = x^e - c1
    g2 = (x+diff)^e - c2

    def gcd(g1, g2):
        while g2:
            g1, g2 = g2, g1 % g2
        return g1.monic()

    return -gcd(g1, g2)[0]


if __name__ == '__main__':
    n = 17760586611989839530764979012315071619919521509875577626429478606274454241159678043810535746332966623663058670717300715547460779268205588389460820067720466352462776717765410586237571959320858214158134024547312265658490071162506700553971039667651135703115866474963876568547778185684728976673717836120304792047315299189632165445283227749873928756096282732528600539673881253373954330133034705428731024702378983696042092279994846922715729685850148779456313632340984860119547605515841848761494920844946127790173917351501172069819897003567918129263893945312339139192847852630585971500788355587457718254527965657865284126859

    e = 5
    """
    nbits = n.nbits()
    kbits = nbits//(2*e*e)
    print "upper %d bits (of %d bits) is same" % (nbits-kbits, nbits)

    # ^^ = bit-wise XOR
    # http://doc.sagemath.org/html/en/faq/faq-usage.html#how-do-i-use-the-bitwise-xor-operator-in-sage
    m1 = randrange(2^nbits)
    m2 = m1 ^^ randrange(2^kbits)
    c1 = pow(m1, e, n)
    c2 = pow(m2, e, n)
    """
    c1 = 7322210871697596223986977504349300957036993199901476670012435325294500304519612337726472460654356124758843208920397603694130360504515139522603740981236715497784580249917859115941502172046171628503054851377787479584337204426817039508510964061244254857320581516172440458341426708727804523348977179551285187758742308549770306927309773303460270597198571790358077417922907937798973284960219056392812160836982204307918084101150724238061787002416728927764976371024273705145359733084655215153762918243436269136368386630749616150354663589931936137788873890785263318466131986098706097166284510567091187418981129753292655680531
    c2 = 6170338375944805179635034130757907468674440136512277929343909338031208502252825119687936824460408955177940212315598356132098877301132435375696672858646293971606757090532674769732578026333496549247284105121797016613239060172344035118250633668395522209672919153838492143928700498459353175749689128550387441868967841018409595816098415762784686269442751177948752272383779454299316060228992365856212380486591247305369383216244732123770545642612542077417708022443097791807030119137452641911942922053825794933342880548637166670501443895698671024605530585297052471679796225998254296292340039579515125764186427116589410443451
    diff = short_pad_attack(c1, c2, e, n)
    print "difference of two messages is %d" % diff

    #print m1
    m1 = related_message_attack(c1, c2, diff, e, n)
    print m1
    #print m2
    print m1 + diff
