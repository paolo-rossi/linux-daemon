object ServerModule: TServerModule
  OldCreateOrder = False
  Height = 150
  Width = 215
  object httpServer: TIdHTTPServer
    Bindings = <>
    OnCommandOther = httpServerCommandOther
    OnCommandGet = httpServerCommandGet
    Left = 88
    Top = 56
  end
end
