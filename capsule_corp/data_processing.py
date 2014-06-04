from datetime import datetime
import logging

import pandas as pd
from pandas.tseries import offsets

from capsule_corp.naive_engine import naive_guess
from capsule_corp.semantic_engine.cogitation import infer_from_ontology


log = logging.getLogger('test')
activities = pd.Series()

engines = {'naive': naive_guess, 'ontology': infer_from_ontology}
inferences = pd.DataFrame(columns=[engine for engine in engines.keys()])


def analyze_sensor_event(sensor, event):
    log.debug("Now ready to anayze event %s on sensor '%s'" % (sensor, event))
    event['sensor'] = sensor
    event['date'] = datetime.strptime(event['date'],
                                      '%Y-%m-%d %H:%M:%S')
    s = pd.Series()
    for name, engine in engines.items():
        infered = engine(event)
        log.info("Engine '%s' - Inferred: %s" % (name, infered))
        s[name] = infered
    inferences.loc[event['date']] = s


def analyze_activities(activity, details):
    date = datetime.strptime(details['date'],
                             '%Y-%m-%d %H:%M:%S')
    activities[date] = activity


def feedback():
    results = pd.concat([activities, inferences],
                        axis=1).rename(columns={0: 'ground_truth'})
    # fill values forward, change je frequency
    freq = offsets.DateOffset(seconds=5)
    results = results.fillna(method='pad').asfreq(freq, method='pad')
    log.debug(results)

    inference_cols = [col for col in results.columns
                      if col not in ['ground_truth']]
    func_score = (lambda x:
                  len(x[x == results['ground_truth']]) / float(len(x)))
    scores = results[inference_cols].apply(func_score)

    log.info(scores)
    return scores
