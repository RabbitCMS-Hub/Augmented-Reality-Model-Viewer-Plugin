<%'/*
'**********************************************
'      /\      | (_)
'     /  \   __| |_  __ _ _ __  ___
'    / /\ \ / _` | |/ _` | '_ \/ __|
'   / ____ \ (_| | | (_| | | | \__ \
'  /_/    \_\__,_| |\__,_|_| |_|___/
'               _/ | Digital Agency
'              |__/
'**********************************************
'* Project  : RabbitCMS
'* Developer: <Anthony Burak DURSUN>
'* E-Mail   : badursun@adjans.com.tr
'* Corp     : https://adjans.com.tr
'**********************************************
' LAST UPDATE: 28.10.2022 15:33 @badursun
'**********************************************
'*/
Class Augmented_Reality_Model_Viewer_Plugin
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Variables
    '---------------------------------------------------------------
    '*/
    Private PLUGIN_CODE, PLUGIN_DB_NAME, PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_CREDITS, PLUGIN_GIT, PLUGIN_DEV_URL, PLUGIN_FILES_ROOT, PLUGIN_ICON, PLUGIN_REMOVABLE, PLUGIN_ROOT, PLUGIN_FOLDER_NAME, PLUGIN_AUTOLOAD
    Public FILE_USDZ, FILE_GLB, FILE_GLTF, FILE_PATH, PRODUCT_ID, SETTINGS_AR3D_MODULATION
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Register Class
    '---------------------------------------------------------------
    '*/
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Register Class
    '---------------------------------------------------------------
    '*/
    Public Property Get class_register()
        DebugTimer ""& PLUGIN_CODE &" class_register() Start"
        '/*
        '---------------------------------------------------------------
        ' Check Register
        '---------------------------------------------------------------
        '*/
        If CheckSettings("PLUGIN:"& PLUGIN_CODE &"") = True Then 
            DebugTimer ""& PLUGIN_CODE &" class_registered"
            Exit Property
        End If
        '/*
        '---------------------------------------------------------------
        ' Plugin Database
        '---------------------------------------------------------------
        '*/
        Dim PluginTableName
            PluginTableName = "tbl_plugin_" & PLUGIN_DB_NAME
        
        If TableExist(PluginTableName) = False Then
            DebugTimer ""& PLUGIN_CODE &" table creating"
            
            Conn.Execute("SET NAMES utf8mb4;") 
            Conn.Execute("SET FOREIGN_KEY_CHECKS = 0;") 
            
            Conn.Execute("DROP TABLE IF EXISTS `"& PluginTableName &"`")

            q="CREATE TABLE `"& PluginTableName &"` ( "
            q=q+"  `ID` int(11) NOT NULL AUTO_INCREMENT, "
            q=q+"  `URUN_ID` int(11) DEFAULT NULL, "
            q=q+"  `FILE` varchar(255) DEFAULT NULL, "
            q=q+"  `FILE_TYPE` varchar(5) DEFAULT NULL, "
            q=q+"  `ORIGINAL_FILE_NAME` varchar(255) DEFAULT NULL, "
            q=q+"  `YUKLEME_TARIHI` datetime DEFAULT current_timestamp(), "
            q=q+"  `FILESIZES` bigint(30) DEFAULT 0, "
            q=q+"  PRIMARY KEY (`ID`), "
            q=q+"  KEY `IND1` (`URUN_ID`) "
            q=q+"  ) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8; "
            Conn.Execute(q)

            Conn.Execute("SET FOREIGN_KEY_CHECKS = 1;") 

            ' Create Log
            '------------------------------
            Call PanelLog(""& PLUGIN_CODE &" için database tablosu oluşturuldu", 0, ""& PLUGIN_CODE &"", 0)

            ' Register Settings
            '------------------------------
            DebugTimer ""& PLUGIN_CODE &" class_register() End"
        End If
        '/*
        '---------------------------------------------------------------
        ' Plugin Settings
        '---------------------------------------------------------------
        '*/
        a=GetSettings("PLUGIN:"& PLUGIN_CODE &"", PLUGIN_CODE&"_")
        a=GetSettings(""&PLUGIN_CODE&"_PLUGIN_NAME", PLUGIN_NAME)
        a=GetSettings(""&PLUGIN_CODE&"_CLASS", "Augmented_Reality_Model_Viewer_Plugin")
        a=GetSettings(""&PLUGIN_CODE&"_REGISTERED", Now())
        a=GetSettings(""&PLUGIN_CODE&"_CODENO", "1923")
        a=GetSettings(""&PLUGIN_CODE&"_FOLDER", PLUGIN_FOLDER_NAME)
        '/*
        '---------------------------------------------------------------
        ' Register Settings
        '---------------------------------------------------------------
        '*/
        DebugTimer ""& PLUGIN_CODE &" class_register() End"
    End Property
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Register Class End
    '---------------------------------------------------------------
    '*/
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Settings Panel
    '---------------------------------------------------------------
    '*/
    Public sub LoadPanel()
        '/*
        '--------------------------------------------------------
        ' Main Page
        '--------------------------------------------------------
        '*/
        With Response
            '------------------------------------------------------------------------------------------
                PLUGIN_PANEL_MASTER_HEADER This()
            '------------------------------------------------------------------------------------------
            .Write "<div class=""row"">"
            .Write "    <div class=""col-lg-12 col-sm-12"">"
            .Write "    <div class=""alert alert-info cms-style""><strong>Panel Bulunamadı</strong><p>Bu modül herhangi bir ayara sahip değildir!</p></div>"
            .Write "    </div>"
            .Write "</div>"
        End With
    End Sub
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Settings Panel
    '---------------------------------------------------------------
    '*/
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Class Initialize
    '---------------------------------------------------------------
    '*/
    Private Sub class_initialize()
        '/*
        '-----------------------------------------------------------------------------------
        ' REQUIRED: PluginTemplate Main Variables
        '-----------------------------------------------------------------------------------
        '*/
        PLUGIN_CODE             = "AR_MODALVIEWER"
        PLUGIN_NAME             = "Augmented Reality Model Viewer Plugin"
        PLUGIN_VERSION          = "1.0.0"
        PLUGIN_GIT              = "https://github.com/RabbitCMS-Hub/Augmented-Reality-Model-Viewer-Plugin"
        PLUGIN_DEV_URL          = "https://adjans.com.tr"
        PLUGIN_ICON             = "zmdi-group"
        PLUGIN_CREDITS          = "@badursun Anthony Burak DURSUN"
        PLUGIN_FOLDER_NAME      = "Augmented-Reality-Model-Viewer-Plugin"
        PLUGIN_DB_NAME          = "ar_products"
        PLUGIN_REMOVABLE        = True
        PLUGIN_AUTOLOAD         = True
        PLUGIN_ROOT             = PLUGIN_DIST_FOLDER_PATH(This)
        PLUGIN_FILES_ROOT       = PLUGIN_VIRTUAL_FOLDER(This)
        '/*
        '-------------------------------------------------------------------------------------
        ' PluginTemplate Main Variables
        '-------------------------------------------------------------------------------------
        '*/
        SETTINGS_AR3D_MODULATION= Cint( GetSettings(""&PLUGIN_CODE&"_ACTIVE", "0") )
        FILE_USDZ               = Null
        FILE_GLB                = Null
        FILE_GLTF               = Null
        PRODUCT_ID              = IIf(Query.Data("ProductId")="", Null, Query.Data("ProductId"))
        FILE_PATH               = "/content/files/3dfiles/"
        '/*
        '-----------------------------------------------------------------------------------
        ' REQUIRED: Register Plugin to CMS
        '-----------------------------------------------------------------------------------
        '*/
        class_register()
        '/*
        '-----------------------------------------------------------------------------------
        ' REQUIRED: Hook Plugin to CMS Auto Load Location WEB|API|PANEL
        '-----------------------------------------------------------------------------------
        '*/
        If PLUGIN_AUTOLOAD_AT("WEB") = True Then
            '/* Model Viewer '*/
            If Query.Data("VIEW_AR_MODAL") = "Run" Then
                ProductID = Query.Data("ProductID")
                CreateModule()
                Call SystemTeardown("destroy")
            End If

            '/* Hook To '*/
            If SETTINGS_AR3D_MODULATION=1 Then 
                If ARPosible(PRODUCT_ID) = True Then
                    '/* Add Button Style '*/
                    PLUGIN_ADD_TO This, "JS", "dist/js/app.js"
                    PLUGIN_ADD_TO This, "CSS", "dist/css/ar-viewer.css"

                    FILE_GLB = Null
                    FILE_USDZ= Null

                    Set rs3DARFiles = Conn.Execute("SELECT `FILE`, `FILE_TYPE` FROM tbl_urun_3d WHERE URUN_ID="& PRODUCT_ID &"")
                    Do while Not rs3DARFiles.Eof
                        If rs3DARFiles("FILE_TYPE").Value = "GLB" Then
                            FILE_GLB = "/content/files/3dfiles/" & rs3DARFiles("FILE").Value
                        End If
                        If rs3DARFiles("FILE_TYPE").Value = "USDZ" Then
                            FILE_USDZ = "/content/files/3dfiles/" & rs3DARFiles("FILE").Value
                        End If
                    rs3DARFiles.MoveNext : Loop
                    rs3DARFiles.Close : Set rs3DARFiles = Nothing

                    If IsNull(FILE_GLB) AND IsNull(FILE_USDZ) Then
                    Else
                        Dim AR_BUTTON
                            AR_BUTTON = "<ar-button data-prod-id="""& PRODUCT_ID &""" src="""& FILE_GLB &""" ios-src="""& FILE_USDZ &""" show-if-unsupported link="""& PLUGIN_RUN_ALONE_URL(This) &"?VIEW_AR_MODAL=Run&LazyLoad=False&ProductID="& PRODUCT_ID &""" title="""& tmp_product_name &""">See in Augmented Reality</ar-button>"
                        
                        '/* Add Hook To '*/
                        PLUGIN_HOOK "product:image-bottom", Array(This, AR_BUTTON)
                    End If
                End If
            End If
            ' Cms.BodyData = Init()
            ' Cms.FooterData = "<add-footer-html>Hello World!</add-footer-html>"
        End If
    End Sub
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Class Initialize
    '---------------------------------------------------------------
    '*/
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Class Terminate
    '---------------------------------------------------------------
    '*/
    Private sub class_terminate()

    End Sub
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Class Terminate
    '---------------------------------------------------------------
    '*/
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Manager Exports
    '---------------------------------------------------------------
    '*/
    Public Property Get PluginCode()        : PluginCode = PLUGIN_CODE                  : End Property
    Public Property Get PluginName()        : PluginName = PLUGIN_NAME                  : End Property
    Public Property Get PluginVersion()     : PluginVersion = PLUGIN_VERSION            : End Property
    Public Property Get PluginGit()         : PluginGit = PLUGIN_GIT                    : End Property
    Public Property Get PluginDevURL()      : PluginDevURL = PLUGIN_DEV_URL             : End Property
    Public Property Get PluginFolder()      : PluginFolder = PLUGIN_FILES_ROOT          : End Property
    Public Property Get PluginIcon()        : PluginIcon = PLUGIN_ICON                  : End Property
    Public Property Get PluginRemovable()   : PluginRemovable = PLUGIN_REMOVABLE        : End Property
    Public Property Get PluginCredits()     : PluginCredits = PLUGIN_CREDITS            : End Property
    Public Property Get PluginRoot()        : PluginRoot = PLUGIN_ROOT                  : End Property
    Public Property Get PluginFolderName()  : PluginFolderName = PLUGIN_FOLDER_NAME     : End Property
    Public Property Get PluginDBTable()     : PluginDBTable = IIf(Len(PLUGIN_DB_NAME)>2, "tbl_plugin_"&PLUGIN_DB_NAME, "")  : End Property
    Public Property Get PluginAutoload()    : PluginAutoload = PLUGIN_AUTOLOAD          : End Property

    Private Property Get This()
        This = Array(PluginCode, PluginName, PluginVersion, PluginGit, PluginDevURL, PluginFolder, PluginIcon, PluginRemovable, PluginCredits, PluginRoot, PluginFolderName, PluginDBTable, PluginAutoload)
    End Property
    '/*
    '---------------------------------------------------------------
    ' REQUIRED: Plugin Manager Exports
    '---------------------------------------------------------------
    '*/

    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/
    Public Property Let ProductID(ProdID)
        If IsNumericalAndNotZero(ProdID) = False Then
            Exit Property
        End If

        PRODUCT_ID = ProdID

        Set rs3DARFiles = Conn.Execute("SELECT `FILE`, `FILE_TYPE` FROM `"& PluginDBTable &"` WHERE `URUN_ID`="& ProdID &"")
        Do while Not rs3DARFiles.Eof
            If rs3DARFiles("FILE_TYPE").Value = "GLB" Then
                FILE_GLB = FILE_PATH & rs3DARFiles("FILE").Value
            End If
            If rs3DARFiles("FILE_TYPE").Value = "USDZ" Then
                FILE_USDZ = FILE_PATH & rs3DARFiles("FILE").Value
            End If
        rs3DARFiles.MoveNext : Loop
        rs3DARFiles.Close : Set rs3DARFiles = Nothing
    End Property
    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/


    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/
    Public Property Get File(Tipi, Path)
        If Len(Path) < 3 Then 
            Exit Property
        End If

        If IsFileExist( Server.MapPath(FILE_PATH & Path) ) = False Then 
            Exit Property
        End If

        Select Case LCase(Tipi)
            Case "usdz"     : FILE_USDZ     = FILE_PATH & Path
            Case "glb"      : FILE_GLB      = FILE_PATH & Path
            Case "gltf"     : FILE_GLTF     = FILE_PATH & Path
            Case Else 
        End Select
    End Property
    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/
    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/
    Public Sub CreateModule()
        If SETTINGS_AR3D_MODULATION = 0 Then 
            Response.Write "Bu özellik kullanılamaz!"
            Exit Sub
        End If

        If PRODUCT_ID=Null Then 
            Response.Write "ProductID is Missing!"
            Exit Sub
        End If
        If FILE_USDZ=Null Then 
            Response.Write "USDZ Files Missing!"
            Exit Sub
        End If
        If FILE_GLB=Null Then 
            Response.Write "GLB Files Missing!"
            Exit Sub
        End If

        If ARPosible(PRODUCT_ID)=False Then 
            Response.Write "Bu ürün için 3D/AR Modülasyonu Tamamlanmamış!"
            Exit Sub
        End If

        Dim LazyLoad
            LazyLoad = LCase( Query.Data("LazyLoad") )

        With Response 
            .Write "<!DOCTYPE html PUBLIC ""-//W3C//DTD HTML 4.01//EN"" ""http://www.w3.org/TR/html4/strict.dtd"">"
            .Write "<html lang=""en-US"">"
            .Write "    <head profile=""http://www.w3.org/2005/10/profile"">"
            .Write "        <title>WebAR</title>"
            .Write "        <meta charset=""utf-8"" />"
            .Write "        <meta http-equiv=""X-UA-Compatible"" content=""IE=edge"" />"
            .Write "        <meta name=""viewport"" content=""width=device-width, height=device-height, initial-scale=1.0, user-scalable=no;user-scalable=0;"" />"
            .Write "        <script src="""& PLUGIN_ROOT &"dist/js/webcomponents-loader.js""></script>"
            .Write "        <script src="""& PLUGIN_ROOT &"dist/js/intersection-observer.js""></script>"
            .Write "        <script src="""& PLUGIN_ROOT &"dist/js/ResizeObserver.js""></script>"
            .Write "        <script src="""& PLUGIN_ROOT &"dist/js/fullscreen.polyfill.js""></script>"
            ' .Write "        script src="""& PLUGIN_ROOT &"js/prismatic.min.js""></script>"
            .Write "        <link rel=""prefetch"" href="""& PLUGIN_ROOT &"dist/img/loading.svg"" />"
            .Write "        <link rel=""prefetch"" href="""& PLUGIN_ROOT &"dist/img/loading.gif"" />"
            .Write "        <link rel=""stylesheet"" href="""& PLUGIN_ROOT &"dist/css/style.css"" />"
            .Write "        <link rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"" />"
            .Write "    </head>"
            .Write "    <body>"
            .Write "        <div class=""page-loader"">"
            .Write "            <div class=""percentage""><strong>Model Loading</strong><small>0%</small></div>"
            .Write "        </div>"
            .Write "        <div class=""grid-container"">"
            .Write "            <model-viewer id=""model-viewer"" class=""a"""
            .Write                  IIf(LazyLoad="false", "", "loading=""eager"" reveal=""interaction"" ")
            .Write "                src="""& FILE_GLB &""" "
            .Write "                ios-src="""& FILE_USDZ &""" " 
            .Write "                ar-modes=""webxr scene-viewer quick-look"" " 
            .Write "                quick-look-browsers=""safari chrome"" " 
            .Write "                alt=""RabbitCMS Model-Viewer"" " 
            .Write "                shadow-intensity=""1"" " 
            .Write "                camera-controls " 
            .Write "                ar auto-rotate " 
            .Write "            >"
            .Write "                <div id=""lazy-load-poster"" slot=""poster""></div>"
            .Write "                <div id=""error"" class=""hide"">AR Özelliği Cihazda Desteklenmiyor</div>"
            .Write "                <div id=""button-load"" slot=""poster"">Modeli Yükle</div>"
            .Write "                <button class=""ActiveButton"" slot=""ar-button"">"
            .Write "                    <i class=""fa fa-spinner fa-spin"" style=""display:none;""></i> AR Aktifleştir"
            .Write "                </button>"
            .Write "            </model-viewer>"
            .Write "        </div>"
            .Write "        <script>let PLUGIN_ROOT='"& PLUGIN_ROOT &"';</script>"
            .Write "        <script src="""& PLUGIN_ROOT &"dist/js/jquery.min.js""></script>"
            .Write "        <script src="""& PLUGIN_ROOT &"dist/js/modelviewer.js""></script>"
            ' .Write "      <script type=""module"" src=""https://unpkg.com/@google/model-viewer/dist/model-viewer.js""></script>"
            .Write "        <script type=""module"" src=""https://unpkg.com/@google/model-viewer@v0.3.1/dist/model-viewer.js""></script>"
            ' .Write "        <script nomodule src=""https://unpkg.com/@google/model-viewer/dist/model-viewer-legacy.js""></script>"
            .Write "        <script nomodule src=""https://unpkg.com/@google/model-viewer@v0.3.1/dist/model-viewer-legacy.js""></script>"
            .Write "    </body>"
            .Write "</html>"
        End With
    End Sub
    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/
    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/
    Public Function ARPosible(ProductID)
        DebugApp "ARPosible("& ProductID &")<br>", ""

        If IsNumericalAndNotZero(ProductID) = False Then
            ARPosible = False
            Exit Function
        End If

        ARPosible = False

        Dim rsPosible
        Set rsPosible = Conn.Execute("SELECT IF( ( (SELECT COUNT(DISTINCT FILE_TYPE) FROM `"& PluginDBTable &"` WHERE URUN_ID="& ProductID &" AND FILE_TYPE = 'USDZ' GROUP BY FILE_TYPE) + (SELECT COUNT(DISTINCT FILE_TYPE) FROM `"& PluginDBTable &"` WHERE URUN_ID="& ProductID &" AND FILE_TYPE = 'GLB' GROUP BY FILE_TYPE) )=2, 1,0 ) AS RESULT")
        If Not rsPosible.Eof Then 
            ARPosible = IIf( Cint(rsPosible("RESULT"))=0, False, True)
        End If
        rsPosible.Close : Set rsPosible = Nothing
    End Function
    '/*
    '---------------------------------------------------------------
    '
    '---------------------------------------------------------------
    '*/
End Class 
%>