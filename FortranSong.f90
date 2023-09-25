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
    query = 'Trying to create a music video challenge for the month (September 2023) and would like you to return a theme ' &
        // 'for each day in the form of \"a video featuring\" followed by the theme for the day. ' &
        // 'Two days should be free choice days with no theme, and should not be on consecutive days. ' &
        // 'Themes should not exactly repeat, and should not be direct types of music. ' &
        // 'Try to space out similar themes by 7 days. ' &
        // 'Return just the data in the form of REM YYYY-MM-DD CAL theme, one per line for each day. ' &
        // 'The rem at the start and exact line format is important.'
    call GetAPICompletion(apiKey,query)

    !Extract response
    call ExtractJSON(message)

    !Generate Calendar Output with response

    print *,"Content:"
    print *,message
end program Song