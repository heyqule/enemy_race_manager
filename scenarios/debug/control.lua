require('util')
local scenarios_helper = require('__enemyracemanager__/scenarios/shared.lua')

local blueprint_string = '0eNrVXdtyHDly/Rc+i3Zl4j7hz/CLY2NC0ZJamo7hzc3m7MoT+nd3k2KzJFZWngOIjvC+7IgSD4CsA5wEMoH8++LD1cP2br+7OVz89vfF7uPtzf3Fb//4++J+9+Vmc3X62eHr3fbit4vdYXt98e7iZnN9+tP+9sPt3e3+cPHt3cXu5tP2Xxe/ybd37q9t/3W3397fXx72m5v70+9ffthezUH02+/vLrY3h91ht33qyOMfvr6/ebj+sN0fWzlj3R9ub7aX/9xcXR3x727vj79ye3Nq+Qhzmad/S+8uvh7/Kxz/69upaz8BKQgkHlDAgFL1gCII1DygBAJlDyiDQMUDKiBQ9IAqCJQ8oAYCqQckE4gUXCSQ28nltoDkTi65BWR3dNktIL2jS28B+R1dfgtI8OgSXECGR5fhAlI8uhQXkOPR5biCHI8uxxXkePTXb5Dj0eW4ghwPLscV5HhwOa4gx4PLcQU5HlyOK8jx4HJcQY4Hl+MKcjy4HA8gx4PL8QByPLgcDyDHg++kgBxXl+MB5Li6HA8gx9XleAA5ri7HA8hxdTkeQI6ry/EAclxdjkeQ4+pyPIIcV5fjEeS4uhyPIMfF98RBjovL8fjC8S+bw3YJ40d2v7v4tNtvPz79C11CzC5iIRFBzovL+VjdviWybyD3xeV+ArkvLvcTyH1xuZ9A7ovL/QRy36V+Aqnvb0LB1d1d3BO4uLtre0J9dBcI3YW6QOjK7m7UUefFBQK57VI7o9R2gTBm+zgYsf2BYbz2LY3R2v/0GKtdLmaM1O7kyBin/SMjjNLu8lEwRrvrWcEI7S6wBeSzS+iCEdpXoYIx2hfGglHa1+qCcVpcUheM1L5nUzBWi0vritFaXF5XjNe+i1oxYvtec8WY7TvyFWO2v7eoGLP97U4FF2uX2RVjtr8prBiz/X1qxZjtb50bxmx/N9/oGM/p1GIRiQ7ymEiB7lMzkCLdJwspsZEnEymzoScTqbCxJxOpssEnE6mx0ScLSaaJjT/ZUMJGoGwoZUNQNlRgY1A2VGSDUDZUYqNQNlRmw1A2VGHjUDZUZQNRNlRjI1EmFBrajD7b0dhm9NmOBjejz3Y4uumzHQ5v+mxH45vBZzsa4Aw+29EIZ/DZjoY4g892NMYZfLajQc7gsx2Ncgaf7WiYM/hsh+OcPtvhQKfPdjTSqT7b0VCn+mxHY53qsx0NdqrPdjTaqT7b0XCn+mxH453qsx0NeKrPdjji6bMdDnn6bEdjnuKzHQ16is/2WdTTjVI9grhxGwkVD1OhkI2NU5kDngVC3UAV2Ds0Iir+LEBDouLPAjgm6s8COCjqz4KYyGiVjZTJcJWNVMh4lY1UyYCVjdTIiJWJhEY//dUejX76NEejnz7L0einT3I0/OlzHIx/AkCZC1zZQIWLXNlAlQtd2UCNi12ZQGD8058nYPzTn7pg/NNfTcD4p7/AgQFQf80FI6CADoAxUECcwCgooJhgHBSQcTASKj69wVgo4PiA0VDxCQ7GQ8VnOBoR9SmOhkR9joMxUcDjB4OiwDYEjIoCeyMwLAps2MC4KLCLBAOjwNYWjIzO9tvVQlIypGUjBbZP5ugi2ycTKdExrWxBZTqoZUIVulfFgqp0r0yoF55fbe63+8vDw36/PSzGo54HuHwnY4KB0jqQwEBhHUhhIFkHCijQaV+zBhRhIMfYCQZyjJ1hIMfYBQZyjP3C7c9Xx/8//LG//ecaXni2ebJuC8EUD6tW1wmmeEjrQDDFQ1gHgikeZB0Ipri2dSCY4uoYO5E80LTOA51grqtjdZjr6li9okDiWB2muKxbXWCKyzrFBaa4rBt7FhXFeCDi8EBgrq8bXWCqOzaHF3PH5DC/HYvD9F5nt6DsdmAaR4DgfH5FKb5ubUUJvv7xFV3B17moKKdl3diKctqZtYpy2llGZpFP6OOflzfz66PkdlZcRcntSICiK7ejSWDYc7YPy9alYWH3YSaSsn0qFlJg+2QiRXoXFi2oRO/CTKhM98oiOHrRc9YrE6rSe8O4DPRC8rvd3fbycHv5ZX/7cPNpPVkx/hyfzItX06cfwNeTFq0PMAtyuj2cJeOBPVQCvNnguggeCPCJBY84+CypCTRLIsCV7XkmwIXtecHBZ2sS2PNKgAe258RMlEr2PE0EOMuWRMxQYdmS1FtDqruEpOBhNB8jehjZx0geRvExsocRfYzirss+BjEX2KmQ8KkgJJ0yPhFYtcv4NGCVJOMyJRPbbVylJLH9xkVKWOnO3mRS37nLuBQpK9C5sNuHZQ8NDA6rv3SAwWH1F7JCb2ksR7bQWxoTSWlHXS2oQDvqJhS/qQkWFL+pMaHIvfv87pQCc7MUwvE3OzlL53y4WembPgMtwzQQZlqFmcWKV2FOPuIajIAweR1GQZi4DhNAmHUTz+LD6zCOiRMGExwTZxDGMXEBYRwTgywOjolBFod1EzeQxbpu4gayWNdN3EAW67qJG8hiXTdxA1msjolBFotjYpDF4pgYZLE4JgZZLI6JQRbLqonDROxmq6czYQLJnNf7hK7I6ygolddRMCY7RsZ47PQEY7FjFIzDzvfBGFzXQTD+OvQVbBFen0tBMNquT+wgGG3XV5kgGG3Xl7wg+G5RXR83wLHb8/5Ll3Eyu9dRq0eF3euYSPSe0LQSvSe0kNC7rLOdjvkEqdA7HROK3xWKBcXvCk2oSIdvpmUg4qB+tuUyrQU6Hel5UZFlmBeif97cHy53N8cxHo5/tfrUBPQ4Y5hFd42X/VdfjgAbaR2N+GScRYJdu/zIxx+6HBexBccWFlt5c8xCcZjNZ4FkvJHGNhJhK80GAFop4diNxc4dxsmscUpHI4VtpOJWyqyVGo5dSOxZLBs3TiSNM4t1440kthHFrRRZKwUcO7HYscM4rLzMIt94I4FtJONWUtZKuPbO+g1id2hvZLU3dmhvFLKRhCtxZJU44UocWSVOHUocWCVOHUocWCVOuBIHVokTrsSBVeLUocSBVeLUocSBVeKEK3FglTjhShxYJc4dShxYJc4dShxYJc64EgdWiTOuxIFV4tyhxIFV4tyhxIFV4owrcWCVOONKHFglzh1KHFglzh1KHFglLrgSB1aJC67EgVXi0qHEyipx6VBiZZW44EqsrBIXXImVVeLSocTKKnHpUGJllbjgSqysEhdciZVV4tqhxMoqce1QYmWVuOJKrKwSV1yJlVXi2qHEyipx7VBiZZW44kqsrBJXXImVVeLaocTKKnHtUGJllbjhSqysEjdciZVV4tahxMIqcetQYmGVuOFKLKwSN1yJhVXi1qHEwipx61BiYZW44UosrBI3XImFVOI4dSixkEocpw4llsQ2giuxRNZKuBJLYrE7lFiUNU6HEktgG8GVWJS1Eq7EEljsDiWWiTVOhxILqcRRcCUWUomj4EoswmJrT17ehGG/FuAj8Hb/1IBl+jUFfndx+Hp3wtvd3D0cLhYbxQW5srbC9bix0B1ynFmKlp7PUZDPcftwML8HLs+ZNRquzqw4a0/omPwe2qHNrDQrEThmTYQrMyvM2rNFZi3Tc1bNtkFskFkTESfVLPRrUb6/u9odltFnaoxYpEeLSasTKVusEhMZW6wQdyRs0YbhN8Ssr4Una9H2gcWX/qi89rILQUeaFrue4Ula7HqAp2ixi1hHghYrgB3pWayO48lZrA7iqVmseHckZhXWLLzAsh4tnpTF+n94ShbrtHYkZDXWLLzIkmerEU/GYndCeCoWu33rSMSijwE68rDo8ww8DYs+DcCzsOhDjI4kLPoYrCMHiz7Pw1Ow6NMwPAOLPsTrSMCij4E78q/o82w8/Yo+Dcazr+hD7I7kq7UwyHIbvNyy8ZyIp17R0RA884oN4sSMz9gVGcyL0Njl0vP188W7VxHPp1oLIS52sAh7o3Ja7iL9+KRxoSoW+vFJEymyfRILKbF9MpHopyelWlD005M2VKV71SyoRvfKgqoTe6NS6jKQcFcgpS3DaMcVyEeb+ysnkVA0w24Ydhy5XmmSpieFKPlcrJk5XXyuJWGTqIzcc3z99RZX0Z6EoZf7gmgjbeS+INhIm0buC6KNvMzH/ebTZv2WmkmUWY7Q/cOH+8Pm8fftChjHWX38he3uyx8fbh/29xe//SO28i5peldi+32xhZdJub/9cHuywcrTRcbiM0sAWgOJ6yAJApnWQTIC8vy+jwVSMKs/+wtLVtd3sRkWrx3RZnPuz7JzVvtaVgkyhXclxaXupq4UHY/YqSsnh9OENEvJsbmwysk0y7xZs26zjduOxjUMGyFsSRb441eTtgyeBnZbr5e4uNhGHmmjYW0UfluArdAJfFnned+y7DClqXV0sEEdnKfTIK8d6swhA6aHSMezNeBnE3arZC4Uwm6VbCR2q2StuUnYrZKNxG+VsgXFb5VMKH6rVCwofqtkQSm/VcrLQOxWqSzDdG2VMiRd2rVVKhh2HNrTWKSZ5ZKsOiLP75UerbrgNFWti3qmeajTJqfK0H7DtEUdgjV7+zKZNvvD7upqu/+6VuDrDGi8PZxmWSIIYPABBXG/16dnz6s9Pj17nunx+RNGDrVfrwWLWhqGXLmCtZE7vJgMeTGhcG7W8mIbOs6vX499uYOtxw+yeBYn8rDZmAWRrcxr94itzGsjsZV5zXkT2cq8NhJdmVeiBUVX5rWh6Mq85pIa6cq8NhRdmVcW3/ZPTFmWl+f7TGsl1iEzYLSrVwlaIVOXRwaVXEjEmzIz7IRhj51gm59szB+zGJrG/DGzt2P+mNnb2Wn11fEr7HcfL693N7ubL5ef9rvFWfryYsbJmwK+3zxpAWzj5UWC120sKuAsaWF38/kIfvh6+fGP7f36/cfv5H7+jff328Ph2K3707/cb69v/9q+fzj+3dWRyNtP73eH7fXxrz5vru637y6efnxy+v9+7YDe/7F9HNfH49w9PHkG17efHv/N4fJqu3ns1+7m0/ak9t9+X/w0xBM1M2fJ4k/uuYBno0Um+iMeWscEn8hFJOcR59maPrn0Z3ujHa/92d5oEw3Y8pzn46IhytSffA32skh/8jXahPYnMqNNhP5EZrQJJJTV1j9n6s8rRnuZ+/OK0SZKf44u2kTtz9FFm2gD+a5gGx3PyQi7ynS8JjM7romQi1t1pA3Mja5hIDsVtdXQoQxoq6FDGdBWPYcyUBG6VMlDmWUBrz2HMgnrIFvE2tipNrbim+lnNbbim41EB8csD6rRwTETia73JmpB0fXebCg+PBYsKD48ZkLRRaxFl4Eaee6x6G/kaeo5PlBkLc2T9GAHDFuHzhAM0uQpDMEGCzYOnSGYvU1DsGZvM76lD/LTh/tVW/rHifaykU8/bOSvb4F9fJ7KyM7TNHod2TNDhyp5GrnlbX5XmevZ5uOfyBXg11M9LkLLwHYcs4nowHYcbCIMbHQtvkgcAAX7nUacb/ALj1w/ez2O5TbKiGMMjqOOtAGOoyevS6FPrRPnfC+rvkpHBzEuzjJbQOdbl7tIxwutCah0vNBESmyfrKVYM9snE4mPFk4WFB8tNKEa3SvjRlAOE90rE0po53taBlLS+ZZlmK64IHTVMIeuuKBg2GNxQYs0YSwuaH71sbig2duxuKDZ29aT4W91MvZUjRXoWmiOQ2n4Zo8VdlIvJ5K3cSiPy/piP+SjoG61OfwEg4k9+kVljvi27mfD/qpN3cPR2ruH68tHCt5fXm++bP5nN9/m6dQRsM1x4HUg+7NWIJjzXSbaMkIbcZmhW+s5TSNtYBM9yYjLDI5DR9oAxxE6vF7oHntOkXPLl/0B4vWQSk7+Wc4NkahorVKzVBsCDfxKld1ALPtoqbHOujXaPLHOuolEJ2Zaq1OmEzNNpFkd681hu+qkVwsjuhjiYiS8H83CyHg/TIzCbhLqMk7l9gjLGpJbhxsPXanPpefov2HQMuLJWwwpQ2f+1vdeyAtZyaiK2enj0Em/2cc0UogV/GZ5pA4r2EYZKWcKtlFHqpmCbSwkb25vtvsvX4+z6Eicz5uP28Wyms8LxruLDw+fP2/37+93/7M9pXSc/7fUXE/NoThxQ+opORSFbGOokifYxlAhT7CNOFIPE2wjjZTDBNvII1UlwTbKSFFJsI06UpsRbKONlGbE2uh5XCSQ87zJSIFDsI2hOoFgG0NlAsE24ki1PbCNNFJsD2wjj9SsA9soIyXrwDbqSOU3sI02UvgNaqP0PIuiE9mGjJRPA9sYqkIGtjFUhAxsI47U8gLbSCOlvMA28khFLLCNMlIQC2yjjtSVAttoI2WlsDZkGqnOBD2kU0RG2mhYGzpSAAq0VRhIq4LexCkSB8I/xta8dOTesN1GniUTWTmLKj2JNYHkYR1oAqRhox69WnjzKr6TSdPSIyGlo2DRy/KMmUhH4iiYifB3ZV50GHrxqszycZAIx+JpZtHIdw+bJLPUHCxqsDxR1DtA1uKcUpZZQo4BkV2ICvfCWpZmCTheLyyIWeKNeyCfLQzBD+RNDMX7USyMgPfDxIjck2qX6WziDDB4llQDxQvKcidzzzsG0EMvJZSOgAH0ZlXBn2iZQRcMuo1EDSxSdlTemaFaFOtJqXmJHph91RFUzMo9qTUvEQroNaAS40iEwrROGkE1v2QeiXSA9igjkQ6wjToSFgDbAJ+hfX5IOBuPvx2du6ksOnezLBn/kYr6Y+9/Ve7Th80ppPj18vpPvdz+98Pu7vrYy9kFFz7vqSTm7Y32NsO6v9t9Oi7V+8cv9n0s0jMW7XlH5NeO5fPD/bGVy/128/Fwu1/6Sl0jC8TIytuMbPuv2/s/t1fbw3F4v4p82BPElxLNWdtO27FpecYmwmjpjYz2FNG9/2O3vfr0S+dtHjmzgV7+Kz2vIcnEOYRpZM8PDmMkhxIbRR7Z+WOjyCM7f3AUHTt/TJ4zt/Nf3pfkjp1/wbrH7vzzcgfxnb/lSWZ8529C4Dt/y/PM+M7fgigTe3snWkjCXt4xkZTtU7KQAtsnEymyqYJxGSf1bNpNS2XuIMFA6dnsQ08WltKz2U8Y9NBm37JoHdrsW+ypQ5t9s69Dm32zrwG/lfOyrcfoUIe29dCbNaUObfJNq2TCKkr2uOAO8MumPv4/uK5TaiXMFswFYNEN6ioC5S4AXVWf3AVglop1dftld3/YfXz6xJd3m/v73V/by7v97V+n7fXqMYXZaR2Bby48sSS8dNa0RSTQmouWRoburrGzfKoO+OLCF8IW7tLdiNn20jcTrS/z+fkQIHKZz3WWKdVhac9VqpMQtvHkoHalQ02mLMTFNsJIGwlrI/7gjq5dFTYNmzruHYO9G3mIBDTySLoEOIqRZ0jAUbSBJrBRSEfhXcj9qSLUocMyC6XjTCRh3Qu95bWi7xFXiR3XK8Evxj5hYs1wYV8wMYEK2SNr+QUrT2l2gejHS4wHY6rSb5eYSML2KVhIyvbJRArs8Ycu40TuwCIso6SOUwXoIcOquQM6YNBl5GjBZEvl6mmFV6lyT1Vf38kU8++LLQwdtFiMCtNIFgH0glYNMnIUYFm8p/DUC6ppjzAS4QftEXt242aP04h/Cj3hVsNQ+CxgbZQOB9YkR4UdatOu7fVxkIFVfhzp4mHQ87J9nPKHy9vd4/q/3X88trr5sv2eoXzYXh9/tjkux8ef6EKcc7GjcSLo5BkuEvszd4pGIsMgAjbsOFDb3378c3sYPD+rkUgoSG8zkOO8u7p93H//oiERi5C6Hxp/Q+kyuGDEY7j6Nsb+yblafBEXtTNxqhzeZjQ/uHhDY6kdL4WZn7kRJ0EeGJNuNr2NlX/2U0cMTaWZvc1wftipPOdida00SfkH1szvHPiX30ysCBv5jWy8fJAxRJzEvzj3y3Vq2T8c4xAe93P1JeGH/a7wzfKxPHu/0eL+ylceok+Dh6NvN5xRsmTcIXZd2Iz7w65vnXF3OL2VN3y+zXi2cI+BcXf4jdz6H85YRhifcTe4uN8X94Kzi4U7weVtTLw53F7vPl5+uL3+MEoX3AXObytKxxVyu39aKX+SpT7y4P6we2KR8aW3vZXHdxrC01/wjuy7v01TIAA6Azj29vKfuz2c9RKMz1PwTUF9W97Nnrcb4VsZKSuHnfSVkapy2EFfR1lIKeQoRmrKgaPoeDkWOx4Gs0l1WovN4MmkUs2BL3evdoRKrVWvsIXjluNZla0bZ/WnsmXjTCC2apx1DF3ZonEmEF0zbrKQ6JJxJhJfMc5C4gvGWUhsvbhpGab1ZJhDT3fXNpHFMBZ72HqKxUGlMGrTnlIYGPRQvTiLiD3vziWXSrOkSPsdmcv4dMnW+EgZgohrEAWCmNYgkJf5L0Neg2gQhH6HODlKN4f97dX7D9s/Nn/tbvdPLtjm0/vTrx/en7Z/R1/rsH/YPv3jmyfaPLpq8vSPPz36Yt97sjv+qcVHX3Ghf22W97jSP4lv3L9q9m/o1SloXWlj6ZSCtfEyf/ebT5v9SmjWmKxtli3Jp6hGZ9K2aSSTObnoI4nM6qKXAfTgotcB9MlFbyOJxx66DKQ1++AD1wpcu8jApQL3k86yKmlwl40yME/diSQD09RdA2RglhYXfGCSZhd8YI5WF3zkajgmQTpUXQdrYuRqODiKodo6WBMdpXWgyjpNyco6i1TRnsI6WPcyd2QwLfePzYG2nBFlc6BNILp6jgEU6OI5FhCbAW0CsQnQJlAge2QZO0SyRyZQIk8LdBmGu0G+POeYDMrzkYM5sI4r49AOvoWOAjvQsUMbeiLO4lwcqaxjWZfJjDy/0/9rKwOe3YPH/epYZKJF4mrquSbAa7os76o/7vYfH3aH98e/+3RG+rzb3x932bsvN5ur058PX+9Orf+12x8eNqep/Nydx39x+V8XT7vwY++eBjmd/nh9t9lvDqdWLv7jlFyL7tNra9Y+ncmrlEpNnJh+xfVik+e54w4sJtlMDuTZD/q1bN9v7za7/dFQH/8cTC9pTBbk2VCvXa+34/p//lKut2kyud46vuv0S7/r4zD3D4/D+CUrWRp5QR5z3dPIUR62AUkDYVxMa1NHFDdxLXQEcSPXQiIK0UlhPnHu3wCCX7jjxnTmWqj0Fg6Tg1mWIbDBXPZ1M38PGtv9ZuG2l8v+fCbDv5YoZzL6a+JErj+W35oT1x8Thw38BguIjfuaQJXskVpAjeyRBTRLX8K2lnEZRqitZVgG6QjoQtdxWwk8smLIIzFdiyY9dUGT+6V/dr1fJ+GZRbZeZyv96Cc9uzsvRwOPtw02++vb/emF1Ytvvy92aSSSpOoNuA54QFB+Vut5l04mi2CLTVQoZPw0rZbtMEs3shHCGoACAGUNIOClbgyEgVw77FN2PCV3bgH8kpn2JqBkuTZLSwJcneW1t/J+mGKda3wmn7UuzlKSYCzs2zTSIVtWwUY6ZOY4SYfMxCEdMmslbaRDZuKwDlmygFiHzARiHbJoAbEOmQF0ejiN9MiygcO5ZFZvOnwy6E3XI3SHUxZB6BGvLJlfZsQts793dnOV4vMEzSZIAWtt5O+U+elhmKdHYY4KYb0Mc2yCOJE8rwS2LYlTvTNa9zOoy30Q4k2Lc91cc0RCPGpxrpBrozGxmzhqn+V7Jfvr98efHRn+74fNzZ9DtRGOAyJetzib580GdL3Z7262/379Z5jf/+kaV+zfVj0tlOsbqePf3J7O258d558KVnxbnqxCvJVxLnNsk5F5LEPf5Nv9vKEES7e83PfyDAkBqskCIvh0tvebsfuf+83u8MfohGXWe1c7hVnv5f9s+uvo9J8/BbhaLqcZwpviY32rk/rG5bmsI5Ec6PnIYxsjSdkRbCPwb2+h3UeLFi1/hO+ez3IJ2dPPmQK1rz+xtLWvOxDEQa1T+ptAvy1/fAC9yHpEpuI4xuoT+EBOxLoXyIMDY7MWyJMDc50N5NGBDUSeHZj7m0AeHthA7OlBMZHY4wMbiT0/MHdwgT1AMJFmCWpkQduKMD5y5wrF6KR2pBFmbDGKHQcLBTtYiJGHziD0yOmCSdB5whXwZGz5WbzW6m8e0UeeubUJPHIF6LyO2PAjd4DOe20TPo3UNtDkwsuviJnZ8CPVRc47Gxs+jMC7zOnI5nlxYwum+FQ+z6UIs7YOVZAEV8dU0FdrzUUlwQ/f2l9qoIpBwQY6UgAStGUW2q8EWTbL7QHcXkNkM399J4Pdi5zbW40OkmULTEZmsmyBDURe2TEJnskrOzYQW7agWUiFLVtgI7GXdqqJxN7asZHYsgUyGUCxwzW1TZUod7kZKB2lCirmdzIVIX2KERd6fJb1FCOYrNEvL2RDNSBNLlb81ZNYPTNUPAQbmwvWU3qgkjbtqfzYyDbwsiDnMpi2UfDZdQ7F2mBloFInOvqO1LZzz9E28Bt051odplHahIO5S2qTgXIi4OjbSOEPtA38nOJcZtQ2Cn4ycS73YYP11FVVcvR5oAgK2gaubdHVtoZrW3S1rfUUNOW0TaaR8qZoG7jSBU/phEg2Cs0F61C6UMnRdyhdaGQbuNKF7BoFV7pQXLAOpQuZHH2H0oVCtoErXfCUTvDaiZchuWAdShc4pRPpULqQyDZwpQvqGgVXuhBcsA6lC0qOvkPpQiDbwJUuTK5RcKUL4oJ1KF0gla7jQZ+XnqNt4EqnrtIprnTqKp12KJ2SSqcdSqek0hGlHtVVOqK4o7pK11POUUml0w6lU1LpFFc6dZUOT6p4CWvZYB1Kp6TS9RRzVFLpAq506ipdwJVOXaXrKeGopNL1lHBUUukCrnTqKh3xAJG6Shc6lE5Jpet5fUhJpYu40omrdBFXOnGVLnYonZBKF3tiyKTSRVzpxFW6iCuduErXk9EhpNLFnou5pNJFXOnEVbqEK524Stf1MAupdKknnZdUuoQrnbhKl3ClE1fpUk+xYlLpujI1SKVLuNKJq3T4QysvOSs22GulW6h6ZHayLrxT9f25qduHw93D4WKx1TyhaSdmx/GEjUtXjLKi3akmBD6HXBnI+BRyVSB3zCBSBHLuoVDxGbS7sQlEhANcExGRbherJxjAmbv0xLnJJogDEs8ixFMwrhyUnuMRcug9cQCyCdxldLWAyCZxpaB0OIzknqfrIReyCdhddA1SYWfR/U614xFxbtyVdxTJj1dhiXMncoUVzl1fOl57Iedr5R1EctGpsJq5AoS//uLqYuW1jNSZxksZKZZ40SrXk8KLVLkOXkdRKnLT3FGgivT6GqxirvvdYBFzdwWN1zDywKfxEkYeWzVcwTwJ0wm/Ljm5WB0axomYdlSUkolsAs+kD65FYBlzz02040ka8hRCp44Lyko2gdcRTa5F8JvI0cVq/c8Pg0OXqf/9YbQJ/JKKJ2cqsJy559YqAyV60aHH/veL0SYSc1GnGabgnwZEu1e4y8DniJ9MwOUBlY46vRW6W6VClqoxeaZkqRobSLgeVRNIuR7ZQGypGhETii1WswKV2F5NJlRme2VDFfZ+kBpAteN+kAjGevC5i8sk32GX+xjA4r2xrcOAd/1jWYdRECatwwQQJqzDRBDGMTF4sSs4JgaLMgXHxAWEcUxcQRjHxCCLw7qJI8hiXTcx+mKFrps4gizWdRNHkMW6buIIslgdE4MsFsfEIIvFMTHIYnFMDLJYHBODLJZ1Eyc4bGlL6ixpwMMwBTCB/F3/RAmk7/oXSiB71z9QQsm7joJx1wHBmOuMB+OtY1qMtetfOWMr7/qikLF115k+4EsIzlzOGG2dhSVjtHVWuVl0fXkyq+9jZ7JAqeXMsu8drPSIfPBgBYnc+dlLXiG3fitIdJnSYELRhUptKHr/pyYUvf+zodhypRINoAwDpXUgpmhpnA8QOGKZhae9Xob1XjYYSFaBKvyE/PP+zwIS3G7nVwIEqpxzBFfynbrnXWbAttIVfhAkrrOnEg+CnO+Ao+yp8GSJ6+yp8GSJDnuIyRIn9qPDkyU41MTrirxcuUU/SoMnUFhfweC6IueNuQVEvJcYIvlR5g8RQDPxefsPzsQWYSusU7MlwgrCfnR4Auk6NRt80qgOe+DJog57iMmipP6FaSLAE0fNMMETSFeXxzALEntAsg4Ey4q0dSBCVqSydkvklBZKXMMETxZJ61Yg1EYSS014AonDHtg1k3X2CKws6+QR/EDI8tODEJrSSP4JPEvK+jiJSVJIdgi+T1nvIzwX1kkmxFRQ9ntUdj2glgNB58f67FBcSibyYysqJOvfSFEZWaeMotNjfXYoPjvYyaG4q5VJLio6X9aXQDig6yzJRDxXhB1q46adUI51CKiaOCIc8H2+sO5hQGeMrHM9oFPGcbsC/HTtOm0CfoprKvAs+Oumz5A77RAKeUJsjbOSp7HBHG0jT2NNpDiRfTK/QBSyTzaSsmexyYQK7FmsDRXZXkUTKrG9sqEy+f3s8RXy+9lILM/t0bE8N5HSxH69YkIJ+/VsKJrp2YSimW5DgUxP1R8gyPTUfCgwge1cg2UFCqxak4oPBZateYmF2FDg8+QvmXAmVAbZfn7hegUKZHsKPhTI9uTPwQyyPflzMINsjz7bwUf4X55oXoEC2R59toOB6ZdnjVegQLZHn+3oY/zRZzv6Gn/02Y4Gp6PPdjQ4HX22o8Hp6LMdDU4Hn+0FZHvw2V5Atgef7QVke/DZXkC2B5/tBWR78NleQbYHn+0VZHvw2V5Btgef7RVke/DZXkG2q8/2CrJdfbZXkO3qs72CbFef7RVku/psryDb1Wd7A9muPtsbyHb12d5AtqvP9gayXX22N5Dt4rO9gWwXn+0NZLv4bG8g28VnewPZLj7bG8h2cdkeJ5Dtoj4UyHYJPtQsb3Rz2K69RyVY9cc4gawX8XsXvd5VtnPJQ2wsInr5yh8tOAWKj4T68j4SunF1kQRd7X0k1LXxkcC1fvKRUNL7SNhKDwBh6zwwNozhgLnBY0gfCOM3QEqM3v48Aa/P+lMXvD7rrybg9dnmA2HUrj4QyGyf2uDdWfG5DV6dBZRUMXID8q4YuwGfQzF6+45QDBi/fe8sBozgvssYwXLwvh8bwXrwvnMd0YLwPsfRivA+x8GS8P7eKIIl4f0NW0TjpT7H0Xipz3E6XmojsfFSG0nJPmUTKZB9spHoaGk1oehoqQ2V2ciWDVXYyJYNVdnIlg3V2MiWCYVGTF8iWzaUsJEtG0rZyJYNFdjIlg0V2ciWDZXYyJYNldnIlg1V2MiWDVXZyJYN1djIlgmFRkyjz3Y0Yhp9tqMR0+izHY2YRp/tcMTUZzscMfXZjkZMg892NGIafLajEdPgsx2NmAaf7WjENPhsRyOmwWc7GjENPtvRiGnw2Q5HTH22wxFTn+1oxFR9tqMRU/XZjkZM1Wc7GjFVn+1oxFR9tqMRU/XZjkZM1Wc7GjFVn+1wxNRnOxwx9dmORkzFZzsaMRWf7WjEVHy2oxFT8dmORkzFZzsaMRWf7WjEVHy2oxFT8dneIh7ZqlioB46c+qyfRU69yBbauQJHtlDESka27NE2MrJlISU0ihp9JCEjWzaSkpEtGymQkS0bKZKRLRspkZEtGylzkS0bqHCRLRuocpEtG6hxkS0TCIyS+qQEg6T+PAFjpP7UBUOk2QeKXGTLBkpcZMsGymRky0YqZGTLRqpkZMtGamRky0QCo6S+z5HAMKnvCCUwTup7ZwkMlPouY0IjpT7F0Uipz3EwUup7/AmMlPrbkARGSv29UQIjpf6GLYGRUn8XmcBIqb+1TYGNItlIbBTpEen3dxe7w/b6+Esfrh62d/vdzemG5V/b/f2T+1lPZwJajruuplK+fftf/RkfPg=='

--local blueprint_string = '0eNqV1l+PnCAQAPDvwrNeHMS/z/0IfWsuF92b3SNx0QA2tRu/e9G77DbdwYIvRiM/YBgcbqwfZpy0VJa1NyZPozKs/XFjRl5UN2zv7DIha5m0eGUJU911exo6gzq1s9Zo2Zowqd7xF2thfU0YKiutxE9nf1je1HztUbsP7kIvLykOeLJantJpHNDh02hcy1Ft3TothTJhi7tz14NCefnox1lvLk+gfF2TJ55H8SLb+exfHSg6v9N3FhXqy5K62KE+d6eDLrYJ9PP5jPrNyN8Ogex+EX0JOs5EgPgXTyBFMJL5kTIUqf1GFWqUfqMONYTfaEKNg6BusQpCDmIKEGgcjYMHGgfxgDzQOFgXEFGGII0iMt0LUnmkqpl7Y7u94bNR7UT5tOcTaKhtD4/s7bSVw4B6Oci+l+JzhC/0GOsYDP6DNUETBs986f9nFrWcJTUuDpHLWZHKI8F1995ponn+FZ+ajg+PS++aNGL/xA2pFFEbHjISKaN2vAepomLiQerIoACQTBNZoGgmz+JKlEeBuCLlUXhcmfIoeVyh8igiqlJtiDu77ae89q9DYeJa9+gOguybHifzIafvaLbXP1GbHeE1iKrhlWgKURX5uv4BYS1now=='


script.on_init(function()

end)


script.on_event(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force

    scenarios_helper.spawn_concrete(surface)
    scenarios_helper.build_base(surface, blueprint_string)
    scenarios_helper.set_tech_level(force, 20)
    scenarios_helper.set_enemy_params(surface)
    scenarios_helper.set_attack_points()
    scenarios_helper.set_game_speed(10)

    if player.character then player.character.destroy() end
    local character = player.surface.create_entity{name = "character", position = player.surface.find_non_colliding_position("character", player.force.get_spawn_position(player.surface), 10, 2), force = force}
    player.set_controller{type = defines.controllers.character, character = character}
    player.teleport({0, 0})
end)
