var data = {
  nodes:{
    eduardo:{'color':'red','shape':'dot','label':'Eduardo'},
    jean:{'color':'green','shape':'dot','label':'Jean'},
    jose:{'color':'blue','shape':'dot','label':'jose'},
    x:{'color':'blue','shape':'dot','label':'X'},
    y:{'color':'blue','shape':'dot','label':'Y'},
    z:{'color':'blue','shape':'dot','label':'Z'},
    a:{'color':'blue','shape':'dot','label':'A'},
    b:{'color':'blue','shape':'dot','label':'B'},
    c:{'color':'blue','shape':'dot','label':'C'}
  },
  edges:{
    eduardo: { jean:{}, jose:{} },
    jose: { x: {}, y: {}, z: {} },
    jean: { a: {}, b: {}, c: {} }
  }
};