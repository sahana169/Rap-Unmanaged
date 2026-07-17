@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: ' Consumption View for Sales Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZSAH_C_SALESITM as projection on ZSAH_I_SLSITM
{
    key SalesDocument,
    key SalesItemNumber,
    @Search.defaultSearchElement: true
    Material,
    Plant,
    @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
    Quantity,
    QuantityUnit,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    /* Associations */
    _SalesHeader : redirected to parent ZSAH_C_SALESHD
}
