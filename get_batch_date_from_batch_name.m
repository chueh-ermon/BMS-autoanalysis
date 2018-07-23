% Get batch_date from batch_name
switch batch_name % Format as 'yyyy-mm-dd'
    case 'batch0'
        batch_date = '20170412';
    case 'batch1'
        batch_date = '2017-05-12';
    case 'batch2'
        batch_date = '2017-06-30';
    case 'batch3'
        batch_date = '2017-08-14';
    case 'batch4'
        batch_date = '2017-12-04';
    case 'batch5'
        batch_date = '2018-01-18';
    case 'batch6'
        batch_date = '2018-02-01';
    case 'batch7'
        batch_date = '2018-02-20';
    case 'batch7pt5'
        batch_date = '2018-04-03_varcharge';
    case 'batch8'
        batch_date = '2018-04-12';
    case 'oed1'
        batch_date = '2018-06-21';
    case 'oed2'
        batch_date = '2018-07-18';
    otherwise
        warning('batch_date not recognized')
end