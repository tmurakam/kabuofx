# -*- coding: utf-8 -*-
require 'builder/xmlmarkup'

class OfxGen
  def generate_all
    stocks = Stock.all
    ofx = generate(stocks)

    path = Rails.public_path + "kabuofx.ofx"
    open(path, "w") do |f|
      f.write(ofx)
    end
  end

  def generate(stocks)
    now = Time.now

    x = Builder::XmlMarkup.new(:indent => 2)
    x.instruct! :xml, version: "1.0", encoding: "UTF-8", standalone: "yes"
    x.instruct! :OFX, OFXHEADER: 200, VERSION: 200, SECURITY: "NONE", OLDFILEUID: "NONE", NEWFILEUID: "NONE"

    out = x.OFX {
      x.SIGNONMSGSRSV1 {
        x.SONRS {
          x.STATUS {
            x.CODE(0)
            x.SEVERITY("INFO")
          }
          x.DTSERVER(datestring(now))
          x.LANGUAGE("JPN")
          x.FI {
            x.ORG("TSB")
          }
        }
      }
      x.INVSTMTMSGSRSV1 {
        x.INVSTMTTRNRS {
          x.TRNUID(0)
          x.STATUS {
            x.CODE(0)
            x.SEVERITY("INFO")
          }
          x.INVSTMTRS {
            x.DTASOF(datestring(now))
            x.CURDEF("JPY")
            x.INVACCTFROM {
              x.BROKDERID("KabuOFX")
              x.ACCTID("Dummy")
            }
            x.INVPOSLIST {
              stocks.each do |stock|
                x.POSSTOCK {
                  x.INVPOS {
                    x.SECID {
                      x.UNIQUEID(stock.code)
                      x.UNIQUEIDTYPE("JP:SIC")
                    }
                    x.HELDINACCT("CASH")
                    x.POSTYPE("LONG")
                    x.UNITS(0)
                    x.UNITPRICE(stock.price)
                    x.MKTVAL(0)
                    x.DTPRICEASOF(datestring(stock.lastdate))
                  }
                }
              end
            }
          }
        }
      }
      x.SECLISTMSGSRSV1 {
        x.SECLIST {
          stocks.each do |stock|
            x.STOCKINFO {
              x.SECINFO {
                x.SECID {
                  x.UNIQUEID(stock.code)
                  x.UNIQUEIDTYPE("JP:SIC")
                }
                x.SECNAME(stock.name)
                x.TICKER(stock.code)
                x.UNITPRICE(stock.price)
                x.DTASOF(datestring(stock.lastdate))
              }
              x.STOCKTYPE("COMMON")
              x.YIELD(0)
            }
          end
        }
      }
    }
    return out
  end

  def datestring(time)
    time.strftime("%Y%m%d%H%M%S[+9:JST]")
  end
end
