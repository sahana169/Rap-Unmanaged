@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for Sales Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZSAH_C_SALESHD provider contract transactional_query as projection on ZSAH_I_SLS
{
    key SalesDocument,
    SalesDocumentType,
    OrderReason,
    SalesOrganization,
    DistributionChannel,
    Division,
    @Search.defaultSearchElement: true
    SalesOffice,
    SalesGroup,
    @Semantics.amount.currencyCode: 'Currency'
    NetPrice,
    Currency,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Salesitem  : redirected to composition child ZSAH_C_SALESITM
}
