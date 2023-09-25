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
    character(len=14) :: monthYear

    !Get API Key from environment variable
    call GetAPIKey(apiKey)

    !Get Month and Year to use
    call GetMonthYear(monthYear)

    !Call API for completion
    query = 'Trying to create a music video challenge for the month (' // trim(monthYear) &
        // ') and would like you to return a theme ' &
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
    call BuildCal(message,monthYear)

    contains

    !Get month and year (this month <= 15, next month otherwise)
    subroutine GetMonthYear(month_and_year)
        implicit none
        character(len=8) :: date
        character(len=10) :: time
        character(len=5) :: zone
        integer :: values(8)
        character(len=9), dimension(12) :: monthNames
        integer :: adjustedMonth, adjustedYear
        character(len=9) :: adjustedMonthName
        character(len=14),intent(out) :: month_and_year

        !Array holding names of the months
        monthNames = [ 'January  ', 'February ', 'March    ', 'April    ', 'May      ', &
                   'June     ', 'July     ', 'August   ', 'September', 'October  ', &
                   'November ', 'December ']

        !Get current date and time
        call date_and_time(date,time,zone,values)

        !Check day to decide month to use
        if (values(3) <= 15) then
            adjustedMonth = values(2)
            adjustedYear = values(1)
        else
            adjustedMonth = mod(values(2), 12) + 1
            adjustedYear = values(1) + (values(2) / 12)
        end if

        ! Get the name of the adjusted month
        adjustedMonthName = monthNames(adjustedMonth)

        write(month_and_year,'(A, I0)') trim(adjustedMonthName) // ' ',adjustedYear
    end subroutine GetMonthYear

    !Build calendar
    subroutine BuildCal(calentries,caldate)
        implicit none
        character(kind=json_ck,len=:),allocatable,intent(in) :: calentries
        character(len=14),intent(in) :: caldate
        character(len=512) :: linebuffer,cmd
        integer :: err,unit,ios

        !Write output to songs.cal
        unit = 1
        open(newunit=unit,file='songs.cal',status='replace',action='write')
        write(unit,*) trim(calentries)
        close(unit)

        !Execute remind to build calendar output (songs.txt)
        cmd = 'remind -cu -w140,, songs.cal ' // trim(caldate) // ' > songs.txt'
        call execute_command_line(trim(cmd),exitstat=err)

        !Read and display songs.txt
        unit = 2
        open(newunit=unit,file='songs.txt',status='old',action='read')
        do
            read(unit,'(A)',iostat=ios) linebuffer
            if(ios /= 0) exit
            print *,trim(linebuffer)
        end do
        close(unit)
    end subroutine BuildCal
end program Song