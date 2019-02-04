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
    case 'oed3'
        batch_date = '2018-07-23';
    case 'oed4'
        batch_date = '2018-07-29';
    case 'oed_0'
        batch_date = '2018-08-28';
    case 'oed_1'
        batch_date = '2018-09-02';
    case 'oed_2'
        batch_date = '2018-09-06';
    case 'oed_3'
        batch_date = '2018-09-10';
    case 'oed_4'
        batch_date = '2018-09-18';
    case 'disassembly_batch'
        batch_date = '2018-10-02';
    case 'disassembly_batch1pt5'
        batch_date = '2018-11-02';
    case 'disassembly_batch2'
        batch_date = '2018-12-05';
    case 'disassembly_batch3'
        batch_date = '2018-12-21';
    case 'batch9'
        batch_date = '2019-01-24';
    case 'batch9pt5'
        batch_date = '2019-01-29';
    otherwise
        warning('batch_date not recognized')
end