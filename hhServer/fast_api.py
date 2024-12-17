from fastapi import FastAPI
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from pydantic import BaseModel
import numpy as np

url_object = URL.create(
    "postgresql+psycopg2",
    username='postgres',
    password='1234qwe',
    host='localhost',
    database='postgres',
    port='5432'
)

engine = create_engine(url_object)

app = FastAPI()


class Input(BaseModel):
    search_text: str


@app.get("/")
def get_():
    return ('hello_w')


@app.get('/get_search_queries')
def get_search_queries():
    df = pd.read_sql_query('select search_text from queries', engine)
    return df.to_dict()


@app.get('/get_vacancies/')
def get_vacancies(search_text: str = 'Data Scientist'):

    query = f'''
        SELECT v.vacancy_id, v.title, v.min_salary, v.max_salary, v.city, v.work_exp from vacancies v
        inner join vacancies_queries vq
            on v.vacancy_id = vq.vacancy_id
        inner join queries q
            on q.search_id = vq.search_id
        where q.search_text = '{search_text}'
    '''
    df = pd.read_sql_query(query, engine)
    df['salary'] = df[['min_salary', 'max_salary']].mean(axis=1)
    df = df.replace(np.nan, None)
    df = df.drop(columns = ['min_salary', 'max_salary'])
    df = df.rename(columns = {'vacancy_id': 'vacancyId', 'work_exp': 'workExperience'})
    return df.to_dict(orient='records')


@app.get('/get_vacancies_test')
def get_vacancies_test():

    query = f'''
        SELECT v.vacancy_id , v.title, v.min_salary, v.max_salary, v.city, v.work_exp from vacancies v
        inner join vacancies_queries vq
            on v.vacancy_id = vq.vacancy_id
        inner join queries q
            on q.search_id = vq.search_id
        where q.search_text = 'Data Engineer'
    '''
    df = pd.read_sql_query(query, engine)
    df['salary'] = df[['min_salary', 'max_salary']].mean(axis=1)
    df = df.replace(np.nan, None)
    df = df.drop(columns = ['min_salary', 'max_salary'])
    df = df.rename(columns = {'vacancy_id': 'vacancyId', 'work_exp': 'workExperience'})
    return df.to_dict(orient='records')
