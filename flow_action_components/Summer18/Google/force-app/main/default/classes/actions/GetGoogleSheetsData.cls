global class GetGoogleSheetsData {
    
    @InvocableMethod(label='Get Google Sheets Data' description='Returns the values from Google Sheets cells that are located at specific address or relative to other specific values')
    global static List<GoogleSheetsResponse> GetGoogleSheetsData(List<GoogleSheetsRequest> requests) {
        List<GoogleSheetsResponse> responses = new List<GoogleSheetsResponse>();
        IGoogleDrive drive = new GoogleDrive(new GoogleAPI());
        for (GoogleSheetsRequest request : requests) {
            GoogleSheetsResponse response = GetGoogleSheetsData.GetGoogleSheetsDataImpl(drive, request);
            responses.add(response);
        }
        return responses;
    }

    public static GoogleSheetsResponse GetGoogleSheetsDataImpl(IGoogleDrive drive, GoogleSheetsRequest request) {
        GoogleSheetsResponse response = new GoogleSheetsResponse();
        try {
            String spreadsheetId = drive.FindFileIdByName(request.SpreadsheetName, FileMimeTypes.GOOGLE_SHEET);
            if (String.isBlank(spreadsheetId)) {
                throw new GoogleException('Spreadsheet with the name "' + request.SpreadsheetName + '" was not found');
            }
            List<List<String>> spreadsheetData = drive.GetSpreadsheetData(spreadsheetId);
            if (!String.isBlank(request.Direction1)) {
                response.Value1 = LocateValue(spreadsheetData, request.Direction1, request.Location1);
            }
            if (!String.isBlank(request.Direction2)) {
                response.Value2 = LocateValue(spreadsheetData, request.Direction2, request.Location2);
            }
            if (!String.isBlank(request.Direction3)) {
                response.Value3 = LocateValue(spreadsheetData, request.Direction3, request.Location3);
            }
            if (!String.isBlank(request.Direction4)) {
                response.Value4 = LocateValue(spreadsheetData, request.Direction4, request.Location4);
            }
            if (!String.isBlank(request.Direction5)) {
                response.Value5 = LocateValue(spreadsheetData, request.Direction5, request.Location5);
            }
        } 
        catch (GoogleException ex) {
            response.IsSuccess = false;
            response.ErrorMessage = ex.getMessage();
        }
        return response;
    }

    private static String LocateValue(List<List<String>> data, String direct, String search) {
        Direction dir = DirectionUtils.parse(direct);
        Address addr = null;
        SheetData sheetData = new SheetData(data);
        if (dir == Direction.ADDRESS) {
            addr = Address.parse(search);
        }
        else {
            addr = sheetData.findAddressByValue(search);
        }        
        //This is for the case where we just couldn't find a value
        if (addr == null) {
            return '';
        }
        if (dir == Direction.RIGHT) {
            addr = addr.shiftRight();
        }
        else if (dir == Direction.BELOW) {
            addr = addr.shiftBelow();
        }
        System.debug('Looking for the value at ' + addr);
        CellValue value = sheetData.getValueByAddress(addr);
        return value.value;
    }

    global class GoogleSheetsRequest {

        @InvocableVariable(required=True label='Sheets File Name' description='Case-sensitive, no extension, name only')
        global String SpreadsheetName;

        @InvocableVariable(required=True label='#1 Direction' description='Allowed values: Address, Right, Below')
        global String Direction1;

        @InvocableVariable(required=True label='#1 Location' description='What value to search for. If related direction is set to "Address", the format should be Excel-like (e.g. "A1")')
        global String Location1;

        @InvocableVariable(label='#2 Direction' description='Allowed values: Address, Right, Below')
        global String Direction2;

        @InvocableVariable(label='#2 Location' description='What value to search for. If related direction is set to "Address", the format should be Excel-like (e.g. "A1")')
        global String Location2;

        @InvocableVariable(label='#3 Direction' description='Allowed values: Address, Right, Below')
        global String Direction3;

        @InvocableVariable(label='#3 Location' description='What value to search for. If related direction is set to "Address", the format should be Excel-like (e.g. "A1")')
        global String Location3;

        @InvocableVariable(label='#4 Direction' description='Allowed values: Address, Right, Below')
        global String Direction4;

        @InvocableVariable(label='#4 Location' description='What value to search for. If related direction is set to "Address", the format should be Excel-like (e.g. "A1")')
        global String Location4;

        @InvocableVariable(label='#5 Direction' description='Allowed values: Address, Right, Below')
        global String Direction5;

        @InvocableVariable(label='#5 Location' description='What value to search for. If related direction is set to "Address", the format should be Excel-like (e.g. "A1")')
        global String Location5;
    }

    global class GoogleSheetsResponse extends ActionResponse {
        
        @InvocableVariable(label='Value #1')
        global String Value1;
        
        @InvocableVariable(label='Value #2')
        global String Value2;
        
        @InvocableVariable(label='Value #3')
        global String Value3;
        
        @InvocableVariable(label='Value #4')
        global String Value4;
        
        @InvocableVariable(label='Value #5')
        global String Value5;
    }
}