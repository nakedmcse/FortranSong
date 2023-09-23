!Song/Video challenge creator in Fortran
program Song
    use iso_fortran_env
    use json_module
    use openai_api
    implicit none

    !Variables
    character(kind=json_ck,len=:),allocatable :: message
    character(len=80) :: apiKey
    character(len=2048) :: query

    !Get API Key from environment variable
    call GetAPIKey(apiKey)

    !Call API for completion
    query = 'Return the days for september 2023, whose first day was friday, as a list of day name and day within' &
        // ' the month number as a simple csv format with no extra text'
    call GetAPICompletion(apiKey,query)

    !Extract response
    call ExtractJSON(message)

    !Generate Calendar Output with response

    print *,"Content: ",message
    print *,"API Key: ",trim(apiKey)
end program Song